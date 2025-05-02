#!/bin/bash

# 1. Atualiza o sistema e instala pacotes básicos e dependências do Odoo
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y  # opcional: atualiza pacotes existentes
# Instala utilitários e bibliotecas necessárias (Python, Wget, etc.)
apt-get install -y gpg curl gnupg lsb-release fuse3
apt-get install -y python3 python3-pip python3-venv build-essential wget git \
                   libxslt-dev libzip-dev libldap2-dev libsasl2-dev libpq-dev \
                   libjpeg-dev node-less wkhtmltox

# 3. Adicionar o repositório oficial do Odoo 17 (nightly builds) e instalar o Odoo
wget -qO- https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/17.0/nightly/deb/ ./" > /etc/apt/sources.list.d/odoo.list
apt-get update -y
# Instala o Odoo 17 Community Edition
apt-get install -y odoo

# 4. Configurar o Odoo para conectar no banco de dados Cloud SQL
ODOO_CONF="/etc/odoo/odoo.conf"
# Garante que o arquivo de configuração exista. Em alguns pacotes, ele pode estar em /etc/odoo/odoo.conf por padrão.
if [ ! -f "$ODOO_CONF" ]; then
    touch "$ODOO_CONF"
fi
# Faz backup da config original, se houver
cp "$ODOO_CONF" "${ODOO_CONF}.orig.$(date +%s)" 2>/dev/null

# Escreve as configurações mínimas necessárias no odoo.conf
cat > "$ODOO_CONF" <<EOL
[options]
admin_passwd = admin
db_host = 10.27.0.8
db_port = 5432
db_user = odoo
db_password = 8Swfs+gbZZVkfmD/Gn2e8Q==
; O parâmetro db_name pode ser definido para fixar um banco específico. Aqui deixaremos sem especificar 
; para permitir escolher/crear o banco via interface web do Odoo.
EOL

# 5. Reiniciar o serviço do Odoo para aplicar configurações
systemctl restart odoo
