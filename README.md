# CouchDB Minihosting

CouchDB Minihosting is a set of scripts that will let you host a CouchDB instance plus an accompanying web project on a Linux server, with https and automatic certificate renewal, all within a matter of minutes.

This works very well with a Ubuntu 24.10 x64 droplet on DigitalOcean, for example.

CouchDB Minihosting is a great starting point for hosting smaller CouchDB projects, prototypes and internal tooling. Depending on how much you’re willing to pay for hardware, you can get quite far with this setup, and happily accommodate a couple of thousand users (your mileage may vary, depending on what you’re doing). At some point, however, the fact that you're running a database inside of Docker will be a limitation you’ll probably want to avoid, and [we can help you with that](#commercial-and-production-deployments). But that’s for future you to deal with! For now, present you can enjoy quick and simple CouchDB hosting.

## What you’ll get

- A CouchDB instance with an admin user
- A haproxy and an nginx setup that:
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

Now run the installation  script
```sh
./install.sh
```

Done. You should now be able to access Fauxton, CouchDB’s admin panel, at `$DOMAIN/_api/_utils/` and log in with `COUCHDB_USER` and `COUCHDB_PASS`. The URL will also be logged to the terminal for convenience. 🎊

# Deploying a Web Project

This repo also contains a deploy script. This is meant to be copied into the repo of the web project you want to run alongside CouchDB, and should be run from that repo. It uses a `deploy` user on the server which was already added by the installation script above.

For more details on the deploy and rollback scripts, please check out the `/deployment/README.md`.

# Tips and Tricks

Some useful Docker commands

```sh
# See which Docker containers are running
$ docker ps
# Inspect the logs of a specific containers. You get the `container id` from `docker ps`
$ docker logs CONTAINER_ID_HERE
# For any of the `docker-compose` commands to work, you must be in /couchdb-mini-hosting
# Shut everything down 
$ docker-compose down
# Start everything up again
$ docker-compose up -d
# See logs from all containers together
$ docker-compose logs
```

### Commercial and Production Deployments

As noted above, this setup isn’t suitable for larger and more critical deployments. If you’re faced with such a task and are unsure about factors like sharding, scaling, high availability etc., [we, Neighbourhoodie Software, are available for consulting and hands-on assistance](https://neighbourhood.ie/). If you’ve already got a functioning CouchDB setup and would like it checked, we offer a [CouchDB Architecture Review](https://neighbourhood.ie/products-and-services/couchdb-architecture-review), where we inspect your setup and prepare a report with actionable suggestions for improvement, if necessary. Ongoing support retainers are also available!

Please [get in touch with our lovely sales team](https://neighbourhood.ie/call) if you have any questions about commercial services. 👩‍💼 👨‍💼 

