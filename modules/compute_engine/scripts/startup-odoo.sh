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
    if [ -n "$3" ]; then
        perm="$3"
    fi
    mkdir -p "$dir"
    chown "$owner" "$dir"
    chmod "$perm" "$dir"
}

export DEBIAN_FRONTEND=noninteractive
trap 'handle_error $LINENO' ERR

log "##################"
log "Otimizando o sistema operacional..."
add_unique_line "vm.dirty_ratio=6" /etc/sysctl.conf
add_unique_line "vm.dirty_background_ratio=3" /etc/sysctl.conf
add_unique_line "vm.vfs_cache_pressure=50" /etc/sysctl.conf
add_unique_line "vm.swappiness=10" /etc/sysctl.conf
add_unique_line "vm.max_map_count=262144" /etc/sysctl.conf
add_unique_line "fs.file-max=2097152" /etc/sysctl.conf
sysctl -p
log "##################"
log "Iniciando configuração do Odoo..."
log "##################"

log "Atualiza sistema e instala gcsfuse"
if ! command -v gcsfuse &>/dev/null; then
    apt-get update && apt upgrade -y
    apt-get install -y curl gnupg lsb-release fuse3 gpg
    GCSFUSE_REPO=gcsfuse-$(lsb_release -c -s)
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" \
    | sudo tee /etc/apt/sources.list.d/gcsfuse.list
    if [ -f /usr/share/keyrings/cloud.google.gpg ]; then
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor >> /usr/share/keyrings/cloud.google.gpg
    else
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    fi
    apt-get update -y && apt-get install -y gcsfuse
else
    log "gcsfuse já está instalado, pulando instalação."
fi

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
#systemctl enable --now mnt-odooplugins.mount
#systemctl enable --now mnt-odooattachments.mount

log "Instalando dependências do Odoo..."
apt-get install -y git python3-pip python3-dev python3-venv \
build-essential libxslt-dev libzip-dev libldap2-dev libsasl2-dev libssl-dev \
libpq-dev libjpeg-dev nodejs npm fontconfig xfonts-75dpi xfonts-base wkhtmltopdf
ln -sf /usr/bin/nodejs /usr/bin/node || true
if ! npm install -g less less-plugin-clean-css 2> /tmp/npm_less_error.log; then
    log "npm install failed: $(cat /tmp/npm_less_error.log)"
    apt-get install -y node-less
fi

log "Instalando Odoo..."
if [ -f /usr/share/keyrings/odoo-archive-keyring.gpg ]; then
    rm -f /usr/share/keyrings/odoo-archive-keyring.gpg
fi
wget -qO- https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/17.0/nightly/deb/ ./" > /etc/apt/sources.list.d/odoo.list
apt-get update && apt-get install -y odoo
ensure_dir "/opt/odoo17/addons" "odoo:odoo"
ensure_dir "/var/lib/odoo" "odoo:odoo"
ensure_dir "/var/log/odoo" "odoo:odoo"
cat > /etc/odoo/odoo.conf <<EOF
[options]
addons_path = /mnt/odoo-plugins,/opt/odoo17/addons
data_dir    = /mnt/odoo-attachments
admin_passwd = admin
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
EOF
chown odoo:odoo /etc/odoo/odoo.conf
chmod 600 /etc/odoo/odoo.conf
systemctl daemon-reload
systemctl enable --now odoo.service
