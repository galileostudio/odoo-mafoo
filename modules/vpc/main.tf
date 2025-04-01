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

output "vpc_self_link" {
  value = google_compute_network.main_vpc.self_link
}

output "subnet_self_link" {
  value = google_compute_subnetwork.main_subnet.self_link
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

  source_ranges = ["0.0.0.0/0"]  # Para testes. Em produção, restrinja para seu IP
  target_tags   = ["packer"]
}