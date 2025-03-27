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
