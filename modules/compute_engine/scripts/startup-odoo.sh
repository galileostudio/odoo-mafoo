#!/bin/bash
set -euo pipefail
exec 1> >(logger -s -t $(basename $0)) 2>&1

_DB_HOST="${db_host}"
_DB_USER="${db_user}"
_DB_PASSWORD="${db_password}"
_PLUGINS_BUCKET="${plugins_bucket}"
_ATTACHMENTS_BUCKET="${attachments_bucket}"
_ODOO_VERSION="${odoo_version}"
_ENVIRONMENT="${environment}"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> /tmp/startup.log
}

handle_error() {
    log "ERROR: Linha $1: Comando falhou"
    exit 1
}

add_unique_line() {
    local line="$1"
    local file="$2"
    grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

ensure_dir() {
    dir="$1"
    owner="$2"
    perm="755"
    mkdir -p "$dir"
    chown "$owner" "$dir"
    chmod "$perm" "$dir"
}

export DEBIAN_FRONTEND=noninteractive
trap 'handle_error $LINENO' ERR

pip3 install libesocial --break-system-packages

log "Cria usuário Odoo e configura FUSE"
if ! id odoo &>/dev/null; then
    useradd -m -s /bin/bash odoo
fi
grep -qxF "user_allow_other" /etc/fuse.conf || echo "user_allow_other" >> /etc/fuse.conf
if ! getent group fuse >/dev/null; then
    groupadd fuse
fi
if ! id -nG odoo | grep -qw fuse; then
    usermod -a -G fuse odoo
fi

log "Criando diretórios e symlinks..."
mkdir -p "/mnt/odooplugins" "/mnt/odooattachments"
chown odoo:odoo "/mnt/odooplugins" "/mnt/odooattachments"
chmod 755 "/mnt/odooplugins" "/mnt/odooattachments"
ln -sf "/mnt/odooplugins" "/mnt/odoo-plugins"
ln -sf "/mnt/odooattachments" "/mnt/odoo-attachments"
chown -h odoo:odoo "/mnt/odoo-plugins" "/mnt/odoo-attachments"

log "Criando Mount Unit para plugins..."
cat > /etc/systemd/system/mnt-odooplugins.mount <<EOF
[Unit]
Description=Mount GCS bucket $_PLUGINS_BUCKET on /mnt/odooplugins
After=network-online.target
Wants=network-online.target
[Mount]
What=$_PLUGINS_BUCKET
Where=/mnt/odooplugins
Type=gcsfuse
Options=rw,allow_other,uid=$(id -u odoo),gid=$(id -g odoo),implicit_dirs,file_mode=0644,dir_mode=0755
[Install]
WantedBy=remote-fs.target
EOF
if [ ! -f /etc/systemd/system/mnt-odooplugins.mount ]; then
    log "Erro ao criar mount unit para plugins."
fi


log "Criando Mount Unit para attachments..."
cat > /etc/systemd/system/mnt-odooattachments.mount <<EOF
[Unit]
Description=Mount GCS bucket $_ATTACHMENTS_BUCKET on /mnt/odooattachments
After=network-online.target
Wants=network-online.target
[Mount]
What=$_ATTACHMENTS_BUCKET
Where=/mnt/odooattachments
Type=gcsfuse
Options=rw,allow_other,uid=$(id -u odoo),gid=$(id -g odoo),implicit_dirs,file_mode=0644,dir_mode=0755
[Install]
WantedBy=remote-fs.target
EOF
if [ ! -f /etc/systemd/system/mnt-odooattachments.mount ]; then
    log "Erro ao criar mount unit para attachments."
fi

log "Habilitando e montando volumes..."
systemctl daemon-reload
systemctl enable --now mnt-odooplugins.mount
systemctl enable --now mnt-odooattachments.mount

ensure_dir "/opt/odoo17/addons" "odoo:odoo"
ensure_dir "/var/lib/odoo" "odoo:odoo"
ensure_dir "/var/log/odoo" "odoo:odoo"
cat > /etc/odoo/odoo.conf <<EOF
[options]
addons_path = /mnt/odoo-plugins,/opt/odoo17/addons
data_dir    = /mnt/odoo-attachments
; admin_passwd = admin
db_host     = $_DB_HOST
db_port     = 5432
db_user     = $_DB_USER
db_password = $_DB_PASSWORD
logfile     = /var/log/odoo/odoo.log
log_level   = info
proxy_mode  = False
without_demo = True
xmlrpc_interface = 0.0.0.0
xmlrpc_port      = 8069
limit_time_real = 1200
limit_time_cpu = 1200
db_filter = ^%odoo$
list_db = False
EOF
chown odoo:odoo /etc/odoo/odoo.conf
chmod 600 /etc/odoo/odoo.conf
systemctl enable --now odoo.service
