#!/bin/bash

# exit when any command fails
set -e

if [ ! -f .env ]; then
  echo "Exiting: Could not find .env file!"
  exit 1
fi

set -a
source .env
set +a

apt install docker-compose

mkdir -p ./data/etc/letsencrypt
mkdir -p ./data/var/lib/letsencrypt
mkdir -p ./data/couchdb

sudo docker run -it --rm \
 -p 80:80 -p 443:443 \
 --name certbot \
 -v "$PWD/data/etc/letsencrypt:/etc/letsencrypt" \
 -v "$PWD/data/var/lib/letsencrypt:/var/lib/letsencrypt" \
 certbot/certbot certonly \
 --standalone -d "$DOMAIN" --email "$CERTBOT_EMAIL" \
 --agree-tos --keep --non-interactive

cd data/etc/letsencrypt/live/mini.backend.lol/
  cat fullchain.pem privkey.pem > haproxychain.pem
cd -

chmod -R go+rx /etc/letsencrypt/
chmod -R go+rx ./data/etc/letsencrypt/

mv renew_certificate_job /etc/cron.d/renew_certificate_job
chmod +x renew-certificate.sh
