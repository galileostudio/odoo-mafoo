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
chown odoo:odoo /mnt/odooplugins /mnt/odooattachments
chmod 755 /mnt/odooplugins /mnt/odooattachments
ln -sf /mnt/odooplugins     /mnt/odoo-plugins
ln -sf /mnt/odooattachments /mnt/odoo-attachments
chown -h odoo:odoo /mnt/odoo-plugins /mnt/odoo-attachments

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
Options=rw,allow_other,uid=$(id -u odoo),gid=$(id -g odoo),implicit_dirs,file_mode=0644,dir_mode=0755

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
Options=rw,allow_other,uid=$(id -u odoo),gid=$(id -g odoo),implicit_dirs,file_mode=0644,dir_mode=0755

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
libpq-dev libjpeg-dev

apt-get install -y \
nodejs npm
ln -sf /usr/bin/nodejs /usr/bin/node || true
npm install -g less less-plugin-clean-css || apt-get install -y node-less

apt-get install -y fontconfig xfonts-75dpi xfonts-base wkhtmltopdf

wget -qO- https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/17.0/nightly/deb/ ./" > /etc/apt/sources.list.d/odoo.list
apt-get update -y

apt-get install -y odoo

mkdir -p /var/lib/odoo /var/log/odoo
chown -R odoo:odoo /var/lib/odoo /var/log/odoo

cat > /etc/odoo/odoo.conf <<EOF
[options]
addons_path = /mnt/odoo-plugins,/opt/odoo17/addons
data_dir    = /mnt/odoo-attachments
admin_passwd = admin
db_host     = ${var.db_host}
db_port     = 5432
db_user     = ${var.db_username}
db_password = ${var.db_password}
logfile     = /var/log/odoo/odoo.log
log_level   = info
proxy_mode  = False
without_demo = True
xmlrpc_interface = 0.0.0.0
xmlrpc_port      = 8069

EOF
chown odoo:odoo /etc/odoo.conf
chmod 600 /etc/odoo.conf

systemctl daemon-reload
systemctl enable --now odoo.service

EOT
  }