#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
echo "Instalando dependências eSocial..."

pip uninstall -y libesocial signxml cryptography pyopenssl lxml zeep dotmap --break-system-packages --root-user-action=ignore || true

echo "Instalando versões coordenadas específicas..."
pip install "cryptography>=38.0.0,<39" --break-system-packages --root-user-action=ignore
pip install "pyOpenSSL>=22.1.0,<25" --break-system-packages --root-user-action=ignore
pip install "signxml>=3.1.0,<4" --break-system-packages --root-user-action=ignore
pip install "lxml>=4.6.3,<6" --break-system-packages --root-user-action=ignore
pip install zeep>=4.1.0 --break-system-packages --root-user-action=ignore
pip install dotmap>=1.3.24 --break-system-packages --root-user-action=ignore
pip install requests>=2.26.0 --break-system-packages --root-user-action=ignore

python3 -c "
from cryptography.hazmat.backends.openssl.x509 import _Certificate
print('Todas as dependências eSocial OK!')
"

echo "Instalando libesocial..."
pip install https://github.com/qualitaocupacional/libesocial/archive/main.zip --break-system-packages --root-user-action=ignore

echo "eSocial configurado"
