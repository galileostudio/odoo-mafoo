terraform {
  backend "gcs" {}
}

resource "google_compute_health_check" "odoo" {
  name    = "odoo-http-health-check"
  project = var.project_id

  check_interval_sec   = 30
  timeout_sec          = 5
  healthy_threshold    = 2
  unhealthy_threshold  = 2

  http_health_check {
    port         = 8069
    request_path = "/web/health"
  }
}

output "health_check_self_link" {
  value = google_compute_health_check.odoo.self_link
}