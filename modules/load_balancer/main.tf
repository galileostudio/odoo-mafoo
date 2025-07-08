terraform {
  backend "gcs" {}
}

resource "google_compute_backend_service" "this" {
  name                            = "${var.application_name}-backend-service"
  project                         = var.project_id
  protocol                        = "HTTP"
  health_checks                   = [var.health_check_self_link]
  port_name                       = "http"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 10
  enable_cdn                      = var.enable_cdn
  session_affinity                = "GENERATED_COOKIE"

  backend {
    group = var.instance_group_self_link
  }
}

resource "google_compute_global_address" "lb_ip" {
  name    = "${var.application_name}-odoo-lb-ip"
  project = var.project_id
}

resource "google_compute_url_map" "url_map" {
  name            = "${var.application_name}-url-map"
  default_service = google_compute_backend_service.this.self_link
}

resource "google_compute_target_https_proxy" "this" {
  name             = "${var.application_name}-https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.this.self_link]
}

resource "google_compute_managed_ssl_certificate" "this" {
  name = "${var.application_name}-managed-ssl"
  managed {
    domains = var.ssl_domains
  }
  project = var.project_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.application_name}-https-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_https_proxy.this.self_link
  ip_address            = google_compute_global_address.lb_ip.address
  port_range            = "443"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.application_name}-http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.application_name}-http-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.http_proxy.self_link
  ip_address            = google_compute_global_address.lb_ip.address
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_firewall" "this" {
  name      = "${var.application_name}-lb-fw-rule"
  network   = var.vpc_name
  direction = "INGRESS"

  # Permitir tráfego apenas do load balancer e health check
  source_ranges = [
    "35.191.0.0/16", # Google Front Ends
    "130.211.0.0/22" # Health Checks
  ]

  allow {
    protocol = "tcp"
    ports    = [var.health_check_port]
  }

  target_tags = ["odoo-prod"]
}

