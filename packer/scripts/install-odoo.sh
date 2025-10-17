#!/bin/bash
set -e

echo "Instalando Odoo 17..."

#!/bin/bash
set -euo pipefail
exec 1> >(logger -s -t $(basename $0)) 2>&1

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


log "Instalando dependências do Odoo..."
apt-get install -y git python3-pip python3-dev python3-venv \
build-essential libxslt-dev libzip-dev libldap2-dev libsasl2-dev libssl-dev \
libpq-dev libjpeg-dev nodejs npm fontconfig xfonts-75dpi xfonts-base wkhtmltopdf
pip3 install sqlparse pandas validate_docbr simplejson lxml_html_clean  --break-system-packages --root-user-action=ignore
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
systemctl daemon-reload

echo "Odoo 17 instalado"
