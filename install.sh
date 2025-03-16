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

# set up ssh key from root to deploy
mkdir -p /home/deploy/.ssh
cp /root/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh

echo "Installing docker-compose…"
apt install -y docker-compose

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

# Concatenate the resulting certificate chain and the private key and write it to HAProxy's certificate file.
cd data/etc/letsencrypt/live/${DOMAIN}/
  cat fullchain.pem privkey.pem > ../../../haproxy/haproxychain.pem
cd -

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

if [ "$ENABLE_CORS" = "true" ]; then
  curl -X PUT http://"$COUCHDB_USER":"$COUCHDB_PASS"@localhost:5984/_node/nonode@nohost/_config/chttpd/enable_cors -d '"true"'
  curl -X PUT http://"$COUCHDB_USER":"$COUCHDB_PASS"@localhost:5984/_node/nonode@nohost/_config/cors/origins -d "\"$ALLOWED_ORIGINS\""
fi

echo "Running Fauxton at https://$DOMAIN/_api/_utils/"

echo "All Done!"
