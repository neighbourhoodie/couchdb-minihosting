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

echo "Adding deploy user to server if necessary…"
# Add deploy user if it doesn’t already exist
id -u deploy >/dev/null 2>&1 || sudo useradd -m deploy

echo "Installing docker-compose…"
apt install docker-compose

echo "Setting up Letsencrypt…"
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

cd data/etc/letsencrypt/live/$DOMAIN/
  cat fullchain.pem privkey.pem > haproxychain.pem
cd -

chmod -R go+rx ./data/etc/letsencrypt/

mv renew_certificate_job /etc/cron.d/renew_certificate_job
chmod +x renew-certificate.sh

echo "Starting Docker Containers…"

docker-compose up -d

until curl -s -X GET http://localhost:5984 | jq -e '.couchdb == "Welcome"' >/dev/null; do
  echo "Waiting for CouchDB to start..."
  sleep 2
done

echo "CouchDB is ready!"
echo "Setting up CouchDB…"

# Make sure docker hasn't stolen deploy’s directory
chown deploy /home/deploy/web

curl -X PUT http://"$COUCHDB_USER":"$COUCHDB_PASS"@localhost:5984/_users
curl -X PUT http://"$COUCHDB_USER":"$COUCHDB_PASS"@localhost:5984/_replicator

echo "Running Fauxton at https://$DOMAIN/_api/_utils/"

echo "All Done!"
