terraform {
  backend "gcs" {}
}

resource "google_compute_health_check" "this" {
  name    = "${var.application_name}-${var.health_check_name}"
  project = var.project_id

  check_interval_sec  = var.health_check_interval_sec
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }
}
