terraform {
  backend "gcs" {}
}

resource "google_compute_health_check" "odoo_hc" {
  name                = "odoo-health-check"
  project             = var.project_id
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    request_path = "/web"
    port         = 8069
  }
}

resource "google_compute_backend_service" "odoo_backend" {
  name                    = "odoo-backend-service"
  project                 = var.project_id
  protocol                = "HTTP"
  health_checks           = [google_compute_health_check.odoo_hc.self_link]
  timeout_sec             = 30
  connection_draining_timeout_sec = 10
  enable_cdn              = var.enable_cdn

  backend {
    group = var.mig_self_link
  }
}

resource "google_compute_url_map" "odoo_url_map" {
  name            = "odoo-url-map"
  default_service = google_compute_backend_service.odoo_backend.self_link
}

resource "google_compute_target_https_proxy" "odoo_https_proxy" {
  name             = "odoo-https-proxy"
  url_map          = google_compute_url_map.odoo_url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.odoo_cert.self_link]
}

resource "google_compute_managed_ssl_certificate" "odoo_cert" {
  name = "odoo-managed-ssl"
  managed {
    domains = var.ssl_domains
  }
  project = var.project_id
}

resource "google_compute_global_forwarding_rule" "odoo_forwarding_rule" {
  name                   = "odoo-https-forwarding-rule"
  project                = var.project_id
  target                 = google_compute_target_https_proxy.odoo_https_proxy.self_link
  port_range             = "443"
  ip_protocol            = "TCP"
  load_balancing_scheme  = "EXTERNAL"
}

# (Opcional) Redirecionamento HTTP para HTTPS
resource "google_compute_target_http_proxy" "odoo_http_proxy" {
  name    = "odoo-http-proxy"
  url_map = google_compute_url_map.odoo_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "odoo_forwarding_rule_http" {
  name                  = "odoo-http-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.odoo_http_proxy.self_link
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
}

output "lb_ip_address" {
  value = google_compute_global_forwarding_rule.odoo_forwarding_rule.ip_address
}

output "health_check_self_link" {
  value = google_compute_health_check.odoo_hc.self_link
}