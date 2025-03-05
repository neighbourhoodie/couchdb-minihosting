#!/bin/bash

set -e

if [ ! -f .env ]; then
  echo "Exiting: Could not find .env file!"
  exit 1
fi

set -a
source .env
set +a

sudo docker run  --rm \
  -e DOMAIN="${DOMAIN}" \
  -e CERTBOT_EMAIL="${CERTBOT_EMAIL}" \
  -v "$PWD/data/etc/letsencrypt:/etc/letsencrypt" \
  --name cert-renew \
  certbot/certbot \
  certonly --webroot --webroot-path=/etc/letsencrypt --non-interactive --agree-tos -d "${DOMAIN}" --email "${CERTBOT_EMAIL}"

# Concatenate the resulting certificate chain and the private key and write it to HAProxy's certificate file.
cd data/etc/letsencrypt/live/$DOMAIN/
  cat fullchain.pem privkey.pem > haproxychain.pem
cd -

# Restart haproxy
docker-compose restart haproxy

