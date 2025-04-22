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

      # ========== CONFIGURAÇÕES BÁSICAS ==========
      export DEBIAN_FRONTEND=noninteractive

      # Atualiza o sistema
      apt-get update -y
      apt-get upgrade -y

      # ========== INSTALAÇÃO DO GCSFUSE ==========
      # Instala dependências
      apt-get install -y curl gnupg lsb-release fuse

      # Configura repositório (corrige extensão .gpg)
      export GCSFUSE_REPO=gcsfuse-$(lsb_release -c -s)
      curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | sudo tee /usr/share/keyrings/cloud.google.gpg > /dev/null
      echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" \
        | sudo tee /etc/apt/sources.list.d/gcsfuse.list

      apt-get update -y
      apt-get install -y gcsfuse

      # ========== CONFIGURA USUÁRIO E PERMISSÕES ==========
      # Cria usuário dedicado para Odoo (UID 1000)
      if ! id odoo >/dev/null 2>&1; then
        useradd -m -u 1000 -s /bin/bash odoo
      fi

      # Configura FUSE para permitir montagem por usuários não-root
      echo "user_allow_other" | sudo tee -a /etc/fuse.conf
      groupadd fuse 2>/dev/null || true
      usermod -a -G fuse odoo

      # Prepara diretórios de montagem
      mkdir -p /mnt/odoo-{attachments,plugins}
      chown -R odoo:odoo /mnt/odoo-*
      chmod 755 /mnt/odoo-*

      # ========== CONFIGURA SERVIÇO GCSFUSE ==========
      cat > /etc/systemd/system/gcsfuse-odoo.service <<EOF
      [Unit]
      Description=Mount GCS Buckets for Odoo
      After=network.target
      Requires=network-online.target

      [Service]
      Type=oneshot
      RemainAfterExit=yes
      User=odoo
      Group=odoo
      ExecStart=/bin/sh -c 'gcsfuse -o allow_other,implicit_dirs,uid=1000,gid=1000 ${var.plugins_bucket_name} /mnt/odoo-plugins && \\
                            gcsfuse -o allow_other,implicit_dirs,uid=1000,gid=1000 ${var.attachments_bucket_name} /mnt/odoo-attachments'
      ExecStop=/bin/fusermount -u /mnt/odoo-plugins ; /bin/fusermount -u /mnt/odoo-attachments

      [Install]
      WantedBy=multi-user.target
      EOF

      # Ativa o serviço
      systemctl daemon-reload
      systemctl enable gcsfuse-odoo
      systemctl start gcsfuse-odoo

      # ========== INSTALAÇÃO DO ODOO ==========
      # Dependências
      apt-get install -y git python3-pip python3-dev python3-venv \
                        build-essential libxslt-dev libzip-dev libldap2-dev \
                        libsasl2-dev libssl-dev libpq-dev nodejs npm wkhtmltopdf

      # Clona repositório Odoo 17
      git clone --depth 1 --branch 17.0 https://github.com/odoo/odoo.git /opt/odoo17

      # Configura ambiente virtual
      python3 -m venv /opt/odoo17/venv
      source /opt/odoo17/venv/bin/activate
      pip install --upgrade pip
      pip install -r /opt/odoo17/requirements.txt psycopg2-binary

      # ========== CONFIGURAÇÃO DO ODOO ==========
      mkdir -p /var/{log,lib}/odoo
      chown -R odoo:odoo /var/{log,lib}/odoo

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

      # ========== SERVIÇO SYSTEMD DO ODOO ==========
      cat > /etc/systemd/system/odoo.service <<EOF
      [Unit]
      Description=Odoo 17
      After=network.target gcsfuse-odoo.service
      Requires=gcsfuse-odoo.service

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

      # Ativa o serviço Odoo
      systemctl daemon-reload
      systemctl enable odoo
      systemctl start odoo

      # ========== VERIFICAÇÃO FINAL ==========
      echo "Verificando serviços..."
      if ! systemctl is-active --quiet gcsfuse-odoo; then
        echo "Erro: gcsfuse-odoo não está ativo!"
        journalctl -u gcsfuse-odoo -b --no-pager
        exit 1
      fi

      if ! systemctl is-active --quiet odoo; then
        echo "Erro: Odoo não está ativo!"
        journalctl -u odoo -b --no-pager
        exit 1
      fi

      echo "Configuração concluída com sucesso!"
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

resource "google_compute_region_instance_group_manager" "odoo_prod_mig" {
  name               = "odoo-prod-mig"
  region             = var.region
  base_instance_name = "odoo-prod-instance"
  target_size        = var.initial_size

  version {
    instance_template = google_compute_instance_template.odoo_prod_template.self_link
  }

  distribution_policy_zones = [ "${var.region}-a", "${var.region}-b", "${var.region}-c"]

  
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
