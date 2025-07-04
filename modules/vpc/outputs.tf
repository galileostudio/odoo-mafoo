output "vpc_self_link" {
  value = google_compute_network.main_vpc.self_link
}

output "subnet_self_link" {
  value = google_compute_subnetwork.main_subnet.self_link
}

output "vpc_name" {
  value = var.vpc_name
}
