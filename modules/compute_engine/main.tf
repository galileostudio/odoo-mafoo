terraform {
  backend "gcs" {}
}
resource "random_password" "odoo_admin" {
  length  = 32
  special = true
}

data "google_compute_image" "ubuntu_2404" {
  project = "ubuntu-os-cloud"
  family  = "ubuntu-minimal-2404-lts-amd64"
    
}
data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}
resource "google_compute_instance_template" "odoo_prod_template" {
  name_prefix  = "odoo-prod-template-"
  machine_type = var.machine_type
  region       = var.region
  
  disk {
    source_image = data.google_compute_image.ubuntu_2404.self_link 
    disk_type    = var.disk_type
    disk_size_gb = var.disk_size_gb
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subnet_self_link
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      set -e

      # ========== CONFIGURAÇÃO BÁSICA ==========
      export DEBIAN_FRONTEND=noninteractive
      apt-get update -y
      apt-get upgrade -y

      # ========== INSTALA GCSFUSE ==========
      export GCSFUSE_REPO=gcsfuse-$(lsb_release -c -s)
      echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
      curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
      apt-get install -y gcsfuse

      # ========== PREPARA DIRETÓRIOS ==========
      mkdir -p /mnt/odoo-{attachments,plugins}
      chown -R root:root /mnt/odoo-*

      # ========== MONTA BUCKETS ==========
      echo "${var.plugins_bucket_name} /mnt/odoo-plugins gcsfuse rw,noauto,user,_netdev,implicit_dirs,allow_other,uid=0,gid=0" >> /etc/fstab
      echo "${var.attachments_bucket_name} /mnt/odoo-attachments gcsfuse rw,noauto,user,_netdev,implicit_dirs,allow_other,uid=0,gid=0" >> /etc/fstab

      mount /mnt/odoo-plugins
      mount /mnt/odoo-attachments

      # ========== INSTALAÇÃO ODOO ==========
      apt-get install -y git python3-pip python3-dev python3-venv \
                        build-essential libxslt-dev libzip-dev libldap2-dev \
                        libsasl2-dev libssl-dev libpq-dev nodejs npm wkhtmltopdf

      git clone --depth 1 --branch 17.0 https://github.com/odoo/odoo.git /opt/odoo17
      python3 -m venv /opt/odoo17/venv
      source /opt/odoo17/venv/bin/activate
      pip install --upgrade pip
      pip install -r /opt/odoo17/requirements.txt psycopg2-binary

      # ========== CONFIGURA ODOO ==========
      mkdir -p /var/{log,lib}/odoo
      cat > /etc/odoo.conf <<EOF
      [options]
      addons_path = /mnt/odoo-plugins,/opt/odoo17/addons
      data_dir = /mnt/odoo-attachments
      admin_passwd = ${random_password.odoo_admin.result}
      db_host = ${var.db_host}
      db_port = 5432
      db_user = ${var.db_username}
      db_password = ${var.db_password}
      logfile = /var/log/odoo/odoo.log
      log_level = info
      proxy_mode = True
      without_demo = True
      EOF

      # ========== SYSTEMD SERVICE ==========
      cat > /etc/systemd/system/odoo.service <<EOF
      [Unit]
      Description=Odoo 17
      After=network.target gcsfuse-odoo.service
      Requires=gcsfuse-odoo.service

      [Service]
      Type=simple
      User=root
      Group=root
      ExecStart=/opt/odoo17/venv/bin/python3 /opt/odoo17/odoo-bin -c /etc/odoo.conf
      Restart=always
      RestartSec=5
      Environment="GCSFUSE_REPO=gcsfuse-\$(lsb_release -c -s)"

      [Install]
      WantedBy=multi-user.target
      EOF

      # ========== GCSFUSE SERVICE ==========
      cat > /etc/systemd/system/gcsfuse-odoo.service <<EOF
      [Unit]
      Description=Mount GCS Buckets for Odoo
      After=network.target

      [Service]
      Type=oneshot
      RemainAfterExit=yes
      ExecStart=/bin/sh -c 'gcsfuse -o allow_other,implicit_dirs,uid=0,gid=0 ${var.plugins_bucket_name} /mnt/odoo-plugins && \
                            gcsfuse -o allow_other,implicit_dirs,uid=0,gid=0 ${var.attachments_bucket_name} /mnt/odoo-attachments'
      ExecStop=/bin/fusermount -u /mnt/odoo-plugins && /bin/fusermount -u /mnt/odoo-attachments

      [Install]
      WantedBy=multi-user.target
      EOF

      # ========== INICIA SERVIÇOS ==========
      systemctl daemon-reload
      systemctl enable gcsfuse-odoo
      systemctl start gcsfuse-odoo
      systemctl enable odoo
      systemctl start odoo

      # ========== VERIFICAÇÃO FINAL ==========
      if ! systemctl is-active --quiet odoo; then
        echo "Falha ao iniciar Odoo"
        journalctl -u odoo -b --no-pager
        exit 1
      fi
      echo "Odoo iniciado com sucesso"
    EOT
  }

  service_account {
    email  = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  tags = ["odoo-prod"]

  lifecycle {
    create_before_destroy = true
  }
}

# ========== AUTO SCALING CONFIG ==========
resource "google_compute_health_check" "odoo_health_check" {
  name = "odoo-health-check"
  check_interval_sec = 30
  timeout_sec = 5

  http_health_check {
    port         = 8069
    request_path = "/web/health"
  }
}

resource "google_compute_instance_group_manager" "odoo_prod_mig" {
  name               = "odoo-prod-mig"
  base_instance_name = "odoo-prod-instance"
  target_size        = 1
  zone               = data.google_compute_zones.available.names[0]

  version {
    instance_template = google_compute_instance_template.odoo_prod_template.self_link
  }

  named_port {
    name = "odoo-http"
    port = 8069
  }

  auto_healing_policies {
    health_check      = var.health_check_self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "odoo_prod_autoscaler" {
  name   = "odoo-prod-autoscaler"
  target = google_compute_instance_group_manager.odoo_prod_mig.self_link
  zone   = data.google_compute_zones.available.names[0]

  autoscaling_policy {
    max_replicas    = var.max_size
    min_replicas    = var.initial_size
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

output "instance_template_self_link" {
  value = google_compute_instance_template.odoo_prod_template.self_link
}

output "mig_self_link" {
  value = google_compute_instance_group_manager.odoo_prod_mig.self_link
}
