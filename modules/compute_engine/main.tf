terraform {
  backend "gcs" {}
}

resource "google_compute_instance_template" "odoo_template" {
  name_prefix  = "odoo-instance-template-"
  project      = var.project_id
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = var.custom_image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subnet_self_link
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      set -e

      ADDONS_MOUNT="/mnt/odoo-addons"
      ATTACHMENTS_MOUNT="/mnt/odoo-attachments"
      INSTALL_DIR="/opt/odoo17"

      mkdir -p \$ADDONS_MOUNT \$ATTACHMENTS_MOUNT

      gcsfuse --key-file /path/to/credentials.json ${var.plugins_bucket_name} \$ADDONS_MOUNT
      gcsfuse --key-file /path/to/credentials.json ${var.attachments_bucket_name} \$ATTACHMENTS_MOUNT

      rm -rf \$INSTALL_DIR
      git clone --depth 1 --branch 17.0 https://github.com/odoo/odoo.git \$INSTALL_DIR
      cd \$INSTALL_DIR

      python3 -m venv odoo-venv
      source odoo-venv/bin/activate
      pip install --upgrade pip
      pip install -r requirements.txt
      pip install psycopg2

      cat <<EOF_CONF > /etc/odoo.conf
        [options]
        addons_path = \$ADDONS_MOUNT,\$INSTALL_DIR/odoo/addons
        data_dir = \$ATTACHMENTS_MOUNT
        admin_passwd = admin123
        db_host = ${var.db_host}
        db_port = 5432
        db_user = odoo
        db_password = change_me
        logfile = /var/log/odoo/odoo.log
        EOF_CONF

          mkdir -p /var/log/odoo
          chmod 755 /var/log/odoo

          cat <<EOF_SERVICE > /etc/systemd/system/odoo.service
        [Unit]
        Description=Odoo 17 Service
        After=network.target

        [Service]
        Type=simple
        User=root
        ExecStart=\$INSTALL_DIR/odoo-venv/bin/python3 \$INSTALL_DIR/odoo-bin -c /etc/odoo.conf
        Restart=on-failure

        [Install]
        WantedBy=multi-user.target
        EOF_SERVICE

          systemctl daemon-reload
          systemctl enable odoo
          systemctl start odoo
    EOT
  }

  tags = ["odoo"]
}
