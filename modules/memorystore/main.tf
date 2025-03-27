terraform {
  backend "gcs" {}
}

resource "google_redis_instance" "this" {
  name                = var.redis_name
  project             = var.project_id
  region              = var.region
  tier                = "STANDARD_HA"
  memory_size_gb      = var.memory_size_gb
  authorized_network  = var.vpc_self_link
  transit_encryption_mode = "SERVER_AUTHENTICATION"
  display_name        = "odoo-redis"
}

output "host" {
  value = google_redis_instance.this.host
}

output "port" {
  value = google_redis_instance.this.port
}
output "private_ip" {
  value = google_redis_instance.this.host
  
}