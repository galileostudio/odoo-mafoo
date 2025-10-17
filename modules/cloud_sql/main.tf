terraform {
  backend "gcs" {}
}

resource "google_sql_database_instance" "this" {
  name             = "${var.application_name}-${var.instance_name}"
  project          = var.project_id
  database_version = var.database_version
  region           = var.region

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_self_link
    }
    edition = "ENTERPRISE_PLUS"

    # Exemplo de HA
    availability_type = "ZONAL"

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = false
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

resource "google_sql_database" "this" {
  name     = var.db_name
  instance = google_sql_database_instance.this.name
  project  = var.project_id
}
