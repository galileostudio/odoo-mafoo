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
      export DEBIAN_FRONTEND=noninteractive

      # 1) Atualiza sistema e instala gcsfuse
      apt-get update -y
      apt-get install -y curl gnupg lsb-release fuse3 gpg
      GCSFUSE_REPO=gcsfuse-$(lsb_release -c -s)

      echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" \
      | sudo tee /etc/apt/sources.list.d/gcsfuse.list

      curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

      apt-get update -y
      apt-get install -y gcsfuse

      # 2) Cria usuário Odoo e configura FUSE
      if ! id odoo &>/dev/null; then
      useradd -m -s /bin/bash odoo
      fi
      echo "user_allow_other" >> /etc/fuse.conf
      groupadd fuse 2>/dev/null || true
      usermod -a -G fuse odoo

      # 3) Prepara diretórios e symlinks
      mkdir -p /mnt/odooplugins /mnt/odooattachments
      chown odoo:fuse /mnt/odooplugins /mnt/odooattachments
      chmod 755 /mnt/odooplugins /mnt/odooattachments
      ln -sf /mnt/odooplugins     /mnt/odoo-plugins
      ln -sf /mnt/odooattachments /mnt/odoo-attachments

      # 4) Cria Mount Unit para plugins
      cat > /etc/systemd/system/mnt-odooplugins.mount <<EOF
      [Unit]
      Description=Mount GCS bucket ${var.plugins_bucket_name} on /mnt/odooplugins
      After=network-online.target
      Wants=network-online.target

      [Mount]
      What=${var.plugins_bucket_name}
      Where=/mnt/odooplugins
      Type=gcsfuse
      Options=rw,allow_other,implicit_dirs,file_mode=0644,dir_mode=0755

      [Install]
      WantedBy=remote-fs.target
      EOF

      # 5) Cria Mount Unit para attachments
      cat > /etc/systemd/system/mnt-odooattachments.mount <<EOF
      [Unit]
      Description=Mount GCS bucket ${var.attachments_bucket_name} on /mnt/odooattachments
      After=network-online.target
      Wants=network-online.target

      [Mount]
      What=${var.attachments_bucket_name}
      Where=/mnt/odooattachments
      Type=gcsfuse
      Options=rw,allow_other,implicit_dirs,file_mode=0644,dir_mode=0755

      [Install]
      WantedBy=remote-fs.target
      EOF

      # 6) Habilita e monta os volumes
      systemctl daemon-reload
      systemctl enable --now mnt-odooplugins.mount
      systemctl enable --now mnt-odooattachments.mount

      # 7) Instalação e configuração do Odoo
      apt-get install -y \
      git python3-pip python3-dev python3-venv \
      build-essential libxslt-dev libzip-dev \
      libldap2-dev libsasl2-dev libssl-dev \
      libpq-dev
      
      apt-get install -y \
      nodejs npm
      ln -sf /usr/bin/nodejs /usr/bin/node || true
      npm install -g less less-plugin-clean-css || apt-get install -y node-less

      apt-get install -y fontconfig xfonts-75dpi xfonts-base wkhtmltopdf

      git clone --depth 1 --branch 17.0 https://github.com/odoo/odoo.git /opt/odoo17

      python3 -m venv /opt/odoo17/venv
      source /opt/odoo17/venv/bin/activate
      pip install --upgrade pip wheel
      pip install redis
      pip install -r /opt/odoo17/requirements.txt psycopg2-binary

      mkdir -p /var/lib/odoo /var/log/odoo
      chown -R odoo:odoo /var/lib/odoo /var/log/odoo

      cat > /etc/odoo.conf <<EOF
      [options]
      addons_path = /mnt/odoo-plugins,/opt/odoo17/addons
      data_dir    = /mnt/odoo-attachments
      admin_passwd = ${random_password.odoo_admin.result}
      db_host     = ${var.db_host}
      db_port     = 5432
      db_user     = ${var.db_username}
      db_password = ${var.db_password}
      logfile     = /var/log/odoo/odoo.log
      log_level   = info
      proxy_mode  = True
      without_demo = True
      xmlrpc_interface = 0.0.0.0
      xmlrpc_port      = 8069

      EOF
      chown odoo:odoo /etc/odoo.conf
      chmod 600 /etc/odoo.conf

      cat > /etc/systemd/system/odoo.service <<EOF
      [Unit]
      Description=Odoo 17
      After=network.target mnt-odooplugins.mount mnt-odooattachments.mount
      Requires=mnt-odooplugins.mount mnt-odooattachments.mount

      [Service]
      Type=simple
      User=odoo
      Group=odoo
      ExecStart=/opt/odoo17/venv/bin/python3 /opt/odoo17/odoo-bin -c /etc/odoo.conf
      Restart=always
      RestartSec=5
      Environment="PATH=/opt/odoo17/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

      [Install]
      WantedBy=multi-user.target
      EOF
      systemctl daemon-reload
      systemctl enable --now odoo.service
    EOT
  }

  service_account {
    email = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  tags = ["odoo-prod"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "odoo_prod_mig" {
  name               = "odoo-prod-mig"
  region             = var.region
  base_instance_name = "odoo-prod-instance"
  target_size        = var.initial_size

  version {
    instance_template = google_compute_instance_template.odoo_prod_template.self_link
  }

  distribution_policy_zones = [
    "${var.region}-a",
    "${var.region}-b",
    "${var.region}-c"
  ]

  named_port {
    name = "http"
    port = 8069
  }

  auto_healing_policies {
    health_check      = var.health_check_self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "odoo_prod_autoscaler" {
  name   = "odoo-prod-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.odoo_prod_mig.self_link

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

output "instance_template_self_link" {
  value = google_compute_instance_template.odoo_prod_template.self_link
}

output "mig_self_link" {
  value = google_compute_region_instance_group_manager.odoo_prod_mig.self_link
}

output "instance_group_self_link" {
  value       = google_compute_region_instance_group_manager.odoo_prod_mig.instance_group
}