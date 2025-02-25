# CouchDB Minihosting

A set of scripts that will let you host a CouchDB instance plus a web project which uses that instance on a Linux server, with https and automatic certificate renewal, all within a matter of minutes.

This works very well with a Ubuntu 24.10 x64 droplet on DigitalOcean, for example.

## What you’ll get in the end

- A CouchDB instance with an admin user
- A haproxy and an nginx instance that:
  - redirect all requests to `/_api` to that CouchDB
  - handle letsencrypt/certbot
  - host your web project at `/`
- A deploy script that will let you deploy or roll back your web project, using a separate `deploy` user on the target system. For details on how to use this, consult `/deployment/README.md`.

These instances are run using Docker.

## Prerequisites

1. A Linux server, and ssh root access to it.
2. A domain name set up to point to that server.
3. The ability to git clone this repo onto the server, or get it there some other way.

# Setup

On your server:

Clone this repository and enter the folder:
```sh
git clone git@github.com:neighbourhoodie/couchdb-mini-hosting.git
cd couchdb-mini-hosting
```

Update the environment variables in `.env`.

- `COUCHDB_USER` and `COUCHDB_PASS`: The credentials you’d like your CouchDB admin user to have
- `DOMAIN`: The domain pointing to your server, without the protocol (eg. `backend.lol`).
- `CERTBOT_EMAIL`: An email address for certificate expiration notifications. You don’t need to set this up anywhere in advance.

```sh
nano .env
```
(To save and exit Nano: `ctrl+o`, enter, `ctrl+x`).

Now run the `start.sh` script
```sh
./start.sh
```

Start the services and check all three are running
```sh
docker-compose up -d
docker ps
```

Finish setup by running the `post-install.sh` script
```sh
./post-install.sh
```

Done. You should now be able to access Fauxton, CouchDB’s admin panel, at `$DOMAIN/_api/_utils/` and log in with `COUCHDB_USER` and `COUCHDB_PASS`. 🎊

To also deploy a web project that uses your new CouchDB instance, to the server that

# Tips and Tricks

Some useful Docker commands

```sh
# See which Docker containers are running
$ docker ps
# Inspect the logs of a specific containers. You get the `container id` from `docker ps`
$ docker logs < container id >
# Shut everything down
$ docker-compose down
# Start everything up again
$ docker-compose up -d
# See logs from all containers together (you must be in /couchdb-mini-hosting for this to work)
$ docker-compose logs
```
