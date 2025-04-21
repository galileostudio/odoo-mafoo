terraform {
  backend "gcs" {}
}

resource "google_compute_network" "main_vpc" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main_subnet" {
  name                   = var.subnet_name
  ip_cidr_range          = var.subnet_cidr
  region                 = var.region
  network                = google_compute_network.main_vpc.self_link
  private_ip_google_access = true
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "google-managed-services-${var.vpc_name}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main_vpc.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main_vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

resource "google_compute_firewall" "allow_packer_ssh" {
  name    = "allow-packer-ssh"
  network = google_compute_network.main_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = google_compute_network.main_vpc.self_link
  region  = var.region
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "nat-config"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

output "vpc_self_link" {
  value = google_compute_network.main_vpc.self_link
}

output "subnet_self_link" {
  value = google_compute_subnetwork.main_subnet.self_link
}

output "vpc_name" {
  value = var.vpc_name
}