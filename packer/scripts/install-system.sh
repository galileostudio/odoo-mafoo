#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Configurando sistema base..."

apt-get update
apt-get upgrade -y

apt-get install -y git python3-pip python3-dev locales \
    python3-venv build-essential libxslt-dev libzip-dev \
    libldap2-dev libsasl2-dev libssl-dev libpq-dev libjpeg-dev \
    nodejs npm fontconfig xfonts-75dpi xfonts-base wkhtmltopdf

sed -i 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g' /etc/locale.gen
echo 'LANG=pt_BR.UTF-8' > /etc/default/locale
locale-gen
echo "Sistema base configurado"
