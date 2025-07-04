terraform {
  backend "gcs" {}
}
locals {
  common_labels = {
    project     = var.project_id
    region      = var.region
    environment = var.environment
    application = var.application_name
    module      = "compute_engine"
    managed-by  = "terraform"
    cost_center = var.cost_center
  }

  name_prefix = "${locals.environment}-${locals.application}"
  zones       = data.google_compute_zones.available.names
  network_tags = concat(
    ["${locals.application}-${locals.environment}"],
    var.allow_health_checks ? ["allow-health-checks"] : [],
    var.allow_ssh ? ["allow-ssh"] : [],
    var.additional_tags
  )
}
resource "null_resource" "validate_zones" {
  count = length(local.zones) > 0 ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'Error: No available zones found in the selected region.' && exit 1"
  }
}
resource "random_password" "this" {
  length  = 32
  special = true
}

data "google_compute_image" "this" {
  project = var.compute_image_project #"ubuntu-os-cloud"
  family  = var.compute_image_family  #"ubuntu-minimal-2404-lts-amd64"   
}

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

resource "google_compute_instance_template" "this" {
  name_prefix  = local.name_prefix
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = data.google_compute_image.this.self_link
    disk_type    = var.disk_type
    disk_size_gb = var.disk_size_gb
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subnet_self_link
  }
  metadata = {
    startup-script = templatefile("${path.module}/scripts/startup-odoo.sh", {
      db_host            = var.db_host
      db_user            = var.db_username
      db_password        = var.db_password != "" ? var.db_password : random_password.this.result
      plugins_bucket     = var.plugins_bucket_name
      attachments_bucket = var.attachments_bucket_name
      admin_password     = var.admin_password_override != "" ? var.admin_password_override : random_password.this.result
      odoo_version       = var.odoo_version
      environment        = var.environment
      log_level          = var.log_level
      proxy_mode         = var.proxy_mode
      max_cron_threads   = var.max_cron_threads
      workers            = var.workers
      additional_addons  = join(",", var.additional_addons_paths)
    })
    enable-oslogin     = "TRUE"
    block-project-keys = "TRUE"

    google-monitoring-enabled = "TRUE"
    google-logging-enabled    = "TRUE"

    odoo-environment = var.environment
    odoo-version     = var.odoo_version
  }

  service_account {
    email = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  tags = local.network_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "this" {
  name               = var.compute_group_manager #"odoo-prod-mig"
  region             = var.region
  base_instance_name = var.base_instance_name #"odoo-prod-instance"
  target_size        = var.initial_size

  version {
    instance_template = google_compute_instance_template.this.self_link
  }

  distribution_policy_zones = local.zones

  named_port {
    name = "http"
    port = var.compute_named_port #8069
  }
  #auto_healing_policies {
  #  health_check      = var.health_check_self_link
  #  initial_delay_sec = 300
  #}
  #}
}

resource "google_compute_region_autoscaler" "this" {
  name   = var.compute_autoscaler_name #"odoo-prod-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.this.self_link

  autoscaling_policy {
    min_replicas    = var.initial_size
    max_replicas    = var.max_size
    cooldown_period = 300

    cpu_utilization {
      target = var.cpu_target
    }
    scale_in_control {
      max_scaled_in_replicas {
        fixed = 1
      }
      time_window_sec = 600
    }
  }
}
