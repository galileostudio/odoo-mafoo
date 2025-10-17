#!/bin/bash
set -e

echo "Otimizando imagem..."

apt-get autoremove -y
apt-get autoclean -y

rm -rf /usr/share/{doc,man,locale}/*
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/archives/*
rm -rf /tmp/*
rm -rf /var/tmp/*

find /var/log -type f -delete
journalctl --vacuum-time=1s

history -c
unset HISTFILE

echo "Imagem otimizada"
