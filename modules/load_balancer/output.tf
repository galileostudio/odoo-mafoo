output "lb_ip_address" {
  value = google_compute_global_forwarding_rule.https.ip_address
}
