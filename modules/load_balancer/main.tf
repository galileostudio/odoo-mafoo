terraform {
  backend "gcs" {}
}
locals {
  validate_ssl_config = (
    var.existing_ssl_certificate_name == null && length(var.ssl_domains) == 0
    ? tobool("ERRO: Você deve fornecer 'existing_ssl_certificate_name' OU 'ssl_domains'")
    : true
  )

  validate_ssl_exclusivity = (
    var.existing_ssl_certificate_name != null && length(var.ssl_domains) > 0
    ? tobool("AVISO: 'ssl_domains' será ignorado quando 'existing_ssl_certificate_name' for fornecido")
    : true
  )
}
data "google_compute_ssl_certificate" "existing" {
  count   = var.existing_ssl_certificate_name != null ? 1 : 0
  name    = var.existing_ssl_certificate_name
  project = var.project_id
}
locals {
  ssl_certificate_self_link = var.existing_ssl_certificate_name != null ? data.google_compute_ssl_certificate.existing[0].self_link : google_compute_managed_ssl_certificate.this[0].self_link
}

resource "google_compute_backend_service" "this" {
  name                            = "${var.application_name}-backend-service"
  project                         = var.project_id
  protocol                        = "HTTP"
  health_checks                   = [var.health_check_self_link]
  port_name                       = "http"
  timeout_sec                     = 10
  connection_draining_timeout_sec = 10
  enable_cdn                      = var.enable_cdn
  session_affinity                = "GENERATED_COOKIE"

  backend {
    group           = var.instance_group_self_link
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_global_address" "lb_ip" {
  name    = "${var.application_name}-odoo-lb-ip"
  project = var.project_id
}

resource "google_compute_url_map" "url_map" {
  name            = "${var.application_name}-url-map"
  default_service = google_compute_backend_service.this.self_link
  # default_url_redirect {
  #  https_redirect = true
  #  strip_query    = false
  #}
}

resource "google_compute_target_https_proxy" "this" {
  name             = "${var.application_name}-https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [local.ssl_certificate_self_link]
  quic_override    = "ENABLE"
}

# Recurso para criar certificado gerenciado (apenas se não houver certificado existente)
resource "google_compute_managed_ssl_certificate" "this" {
  count   = var.existing_ssl_certificate_name != null ? 0 : 1
  name    = "${var.application_name}-managed-ssl"
  project = var.project_id

  managed {
    domains = var.ssl_domains
  }

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

