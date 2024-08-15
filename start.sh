#!/bin/bash

# Periksa jika variabel environment diset
if [[ -z "$NGROK_TOKEN" ]]; then
  echo "Please set 'NGROK_TOKEN'"
  exit 2
fi

if [[ -z "$USER_PASS" ]]; then
  echo "Please set 'USER_PASS' for user: $USER"
  exit 3
fi

# Instalasi dan konfigurasi ZeroTierOne
echo "### Clone and Install ZeroTierOne ###"
git clone https://github.com/zerotier/ZeroTierOne ~/ZeroTierOne
curl -s https://install.zerotier.com | sudo bash

# Atur izin file
sudo chmod 777 -R /var/lib/zerotier-one

# Instalasi Ngrok
echo "### Install ngrok ###"
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok

# Update password pengguna
echo "### Update user: $USER password ###"
echo -e "$USER_PASS\n$USER_PASS" | sudo passwd "$USER"

# Jalankan Ngrok untuk port 22 (SSH)
echo "### Start ngrok proxy for port 22 ###"
ngrok authtoken "$NGROK_TOKEN"
ngrok tcp 22 --log ".ngrok.log" &

# Tunggu Ngrok untuk terhubung dan cetak koneksi SSH
sleep 10
HAS_ERRORS=$(grep "command failed" < .ngrok.log)

if [[ -z "$HAS_ERRORS" ]]; then
  echo ""
  echo "=========================================="
  echo "To connect: $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"
  echo "=========================================="
else
  echo "$HAS_ERRORS"
  exit 4
fi
