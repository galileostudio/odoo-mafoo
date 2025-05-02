terraform {
  backend "gcs" {}
}

resource "google_compute_backend_service" "odoo_backend" {
  name                             = "odoo-backend-service"
  project                          = var.project_id
  protocol                         = "HTTP"
  health_checks                    = [var.health_check_self_link]
  port_name                        = "http"
  timeout_sec                      = 30
  connection_draining_timeout_sec  = 10
  enable_cdn                       = var.enable_cdn
  session_affinity                 = "GENERATED_COOKIE"

  backend {
    group = var.instance_group_self_link
  }
}

resource "google_compute_global_address" "lb_ip" {
  name    = "odoo-lb-ip"      # você pode parametrizar esse nome via var, se quiser
  project = var.project_id
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_global_forwarding_rule" "odoo_forwarding_rule" {
  name                   = "odoo-https-forwarding-rule"
  project                = var.project_id
  target                 = google_compute_target_https_proxy.odoo_https_proxy.self_link
  ip_address             = google_compute_global_address.lb_ip.address
  port_range             = "443"
  ip_protocol            = "TCP"
  load_balancing_scheme  = "EXTERNAL"
}

resource "google_compute_target_http_proxy" "odoo_http_proxy" {
  name    = "odoo-http-proxy"
  url_map = google_compute_url_map.odoo_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "odoo_forwarding_rule_http" {
  name                  = "odoo-http-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.odoo_http_proxy.self_link
  ip_address            = google_compute_global_address.lb_ip.address
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_firewall" "odoo_lb" {
  name          = "odoo-lb-fw-rule"
  network       = var.vpc_name
  direction     = "INGRESS"

  # Permitir tráfego apenas do load balancer e health check
  source_ranges = [
    "35.191.0.0/16",    # Google Front Ends
    "130.211.0.0/22"    # Health Checks
  ]

  allow {
    protocol = "tcp"
    ports    = ["8069"]
  }

  target_tags = ["odoo-prod"]
}

output "lb_ip_address" {
  value = google_compute_global_forwarding_rule.odoo_forwarding_rule.ip_address
}