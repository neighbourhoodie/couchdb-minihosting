#!/bin/bash

set -e

if [ ! -f .env ]; then
  echo "Exiting: Could not find .env file!"
  exit 1
fi

set -a
source .env
set +a

curl -X PUT http://"$COUCHDB_USER":"$COUCHDB_PASS"@localhost:5984/_users
curl -X PUT http://"$COUCHDB_USER":"$COUCHDB_PASS"@localhost:5984/_replicator
