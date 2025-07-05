terraform {
  backend "gcs" {}
}

locals {
  common_labels = {
    project    = var.project_id
    module     = "vpc"
    managed-by = "terraform"
  }

  private_service_cidr = "10.1.0.0/16"
}

resource "google_compute_network" "main_vpc" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "VPC Default - ${var.vpc_name}"

  delete_default_routes_on_create = var.delete_default_routes
}

resource "google_compute_subnetwork" "main_subnet" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.main_vpc.self_link
  private_ip_google_access = true

  description = "Subnet principal para aplicações em ${var.region}"
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "google-managed-services-${var.vpc_name}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  address       = split("/", local.private_service_cidr)[0]
  project       = var.project_id
  network       = google_compute_network.main_vpc.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main_vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

resource "google_compute_firewall" "allow_packer_ssh" {
  name      = "${var.vpc_name}-allow-ssh"
  network   = google_compute_network.main_vpc.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_packer_application" {
  name      = "${var.vpc_name}-allow-application"
  network   = google_compute_network.main_vpc.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = var.allowed_application_ports
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow_internal" {
  name      = "${var.vpc_name}-allow-internal"
  network   = google_compute_network.main_vpc.name
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
}

resource "google_compute_router" "nat_router" {
  name    = "${var.vpc_name}-nat-router"
  network = google_compute_network.main_vpc.name
  region  = var.region
}

resource "google_compute_router_nat" "nat_config" {
  name   = "${var.vpc_name}-nat-gateway"
  router = google_compute_router.nat_router.name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_route" "default_internet_gateway" {
  count            = var.create_default_route ? 1 : 0
  name             = "${var.vpc_name}-default-route"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.main_vpc.name
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}
