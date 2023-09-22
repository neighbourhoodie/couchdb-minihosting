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

chmod -R go+rx /etc/letsencrypt/

sudo docker run -it --rm  -p 80:80 -p 443:443 --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot certonly --standalone -d "$DOMAIN" --email "$CERTBOT_EMAIL" --agree-tos --keep --non-interactive
