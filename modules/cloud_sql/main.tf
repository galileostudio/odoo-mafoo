terraform {
  backend "gcs" {}
}

resource "google_sql_database_instance" "this" {
  name             = var.instance_name
  project          = var.project_id
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_self_link
    }

    # Exemplo de HA
    availability_type = "REGIONAL"

    backup_configuration {
      enabled             = true
      start_time          = "03:00"
      point_in_time_recovery_enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_user" "default" {
  name     = var.db_username
  instance = google_sql_database_instance.this.name
  project  = var.project_id
  password = var.db_password
}

resource "google_sql_database" "odoo_db" {
  name     = var.db_name
  instance = google_sql_database_instance.this.name
  project  = var.project_id
}

output "instance_connection_name" {
  value = google_sql_database_instance.this.connection_name
}

output "private_ip" {
  value = (
    length([
      for ip in google_sql_database_instance.this.ip_address : ip.ip_address
      if ip.type == "PRIVATE"
    ]) > 0 ?
    [
      for ip in google_sql_database_instance.this.ip_address : ip.ip_address
      if ip.type == "PRIVATE"
    ][0] : null
  )
}

output "db_username" {
  value = var.db_username
}

output "db_password" {
  value = var.db_password
  sensitive = true
}
