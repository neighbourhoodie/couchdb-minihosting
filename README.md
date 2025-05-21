# CouchDB Minihosting

> Forget about CouchTo5k, We can do ToCouchIn5Min!

*CouchDB Minihosting* allows you to try out CouchDB in a matter of minutes. It provides you with a CouchDB instance, automatic TLS with Letsencrypt and even allows you to deploy a web project if you’d like to [build](https://neighbourhood.ie/blog/2025/02/05/couchdb-is-great-for-prototypes-and-side-projects) an [Offline First](https://neighbourhood.ie/blog/2024/12/05/realtime-multiuser-kanban-board-with-couchdb) [app](https://neighbourhood.ie/blog/2019/05/10/an-offline-first-todo-list-with-svelte-pouchdb-and-couchdb) with [PouchDB](https://pouchdb.com).

This works very well with a Ubuntu 24.10 x64 VM on a hosting provider of your choice, see [Hosting Providers](#hosting-providers) below for examples. Any VM size will work, even the smallest one.

CouchDB Minihosting is a great starting point for hosting smaller CouchDB projects, prototypes and internal tooling. Depending on how much you’re willing to pay for hardware, you can get quite far with this setup, and happily accommodate a couple of thousand users (your mileage may vary, depending on what you’re doing).

## What you’ll get

- A CouchDB instance with an admin user
- A [haproxy](https://www.haproxy.org) and an [nginx](https://nginx.org) setup that:
  - redirect all requests to `/_api` to that CouchDB
  - handle letsencrypt/certbot for continuous TLS certificates
  - optionally host your web project at `/`
- A deploy script that will let you deploy or roll back your web project. We’ve provided a small example project called Pouchnotes for you to use: [GitHub](https://github.com/neighbourhoodie/pouchnotes), [Blog Post](https://neighbourhood.ie/blog/2025/03/26/offline-first-with-couchdb-and-pouchdb-in-2025).

We are using Docker Compose to set all this up for you.

## Prerequisites

1. A Linux server or virtual machine (VM), and `ssh`  with root access to it.
2. A domain name set up to point to that server.
  - If you don’t want to pay for a top level domain (TLD), here’s a list of free services that let you register a subdomain:
    - https://freedns.afraid.org
    
3. The ability to git clone this repo onto the server, or get it there some other way.

## Setup

On your server:

Clone this repository and enter the folder:
```sh
git clone https://github.com/neighbourhoodie/couchdb-minihosting.git
cd couchdb-minihosting
```

Copy `.env.default` to `.env` and fill out the environment variables:

- `COUCHDB_USER` and `COUCHDB_PASS`: The credentials you’d like your CouchDB admin user to have. Make sure the password is long and unguessable.
- `DOMAIN`: The domain pointing to your server, without the protocol (eg. `backend.lol`).
- `CERTBOT_EMAIL`: An email address for certificate expiration notifications.
- `COUCHDB_PATH`: The path where CouchDB will be mounted. If set to `/`, frontend will be disabled.'
- `ENABLE_CORS`: Set to `true` if you want to enable CORS for your CouchDB.
- `ALLOWED_ORIGINS`: A comma-separated list of origins to allow CORS requests from. Only used if `ENABLE_CORS` is set to `true`.
```sh
nano .env
```
(To save and exit Nano: `ctrl+o`, enter, `ctrl+x`).

> [!IMPORTANT]
> Note: The [install script](/install.sh) assumes you are not using this server for anything else. If you do, please give it a quick look to see if there is anything in there that would conflict with what you already have set up. If you run this on a VM with other things, we assume you are an expert user and generally know what you are doing.

Now run the installation  script
```sh
./install.sh
```

Done. You should now be able to access Fauxton, CouchDB’s admin panel, at `$DOMAIN/_api/_utils/` and log in with `COUCHDB_USER` and `COUCHDB_PASS`. The URL will also be logged to the terminal for convenience. 🎊

## Deploying a Web Project

This repo also contains a deploy script. This is meant to be copied into the repo of the web project you want to run alongside CouchDB, and should be run from that repo. It uses a `deploy` user on the server which was already added by the installation script above.

For more details on the deploy and rollback scripts, please check out the [`/deployment/README.md`](/deployment/README.md).

To get you started, we provide [Pouchnotes](https://github.com/neighbourhoodie/pouchnotes/), a demo project that gets you started with PouchDB, authentication and replication.

## Automatic Certificate Renewal

Certificate renewal is done via a CRON job on the first of each month. The CRON task will live in `/etc/cron.d/renew_certificate_job`, and it calls the `/renew-certificate.sh` script. Logs from that script go to `/var/log/syslog` and have the `renew-cert` prefix.

> [!IMPORTANT]
> Note: The [certificate renewal cronjob](renew_certificate_job) assumes that the path to the repo is `/root/couchdb-minihosting`, if you’ve cloned the repo somewhere else, please check `/etc/cron.d/renew_certificate_job` and modify that if necessary. 

## Tips and Tricks

Some useful Docker commands:

```sh
# See which Docker containers are running
$ docker ps
# Inspect the logs of a specific containers. You get the `container id` from `docker ps`
$ docker logs CONTAINER_ID_HERE
# For any of the `docker-compose` commands to work, you must be in /couchdb-minihosting
# Shut everything down 
$ docker-compose down
# Start everything up again
$ docker-compose up -d
# See logs from all containers together
$ docker-compose logs
```

## Roadmap — Please Help!

- [ ] add backups
- [ ] Add way to run this on local dev machines and proper TLS certs but without Letsencrypt
- [ ] Add nice error pages
- [ ] Add metrics collector and populate a default dashboard with CouchDB metrics
- [ ] Document how to add a backend container
- [ ] Add tests / CI


## Hosting Providers

CouchDB Minihosting works with any generic hosting service, here are a few to get you started, if you don’t already have one.

- https://www.netcup.com
- https://alfahosting.de
- https://digitalocean.com
- https://www.hetzner.com
- https://www.ovhcloud.com/de/
- https://www.vultr.com

## FaQ

*Why HAProxy, nginx & certbot instead of Caddy?* — First off, Caddy is great. For CouchDB Minihosting, we used the components that we run in production and that have not let us down in over 15 years of deploying CouchDB in production, so we are most comfortable supporting these. Secondly, we hope this project ([eventually](#roadmap--please-help)) become a blueprint for folks to learn what it takes to set up a production-grade CouchDB installation. That is not to say Caddy can’t serve this purpose or that we’re not open to changes, but for the time being we’d prefer contributions from the [roadmap](#roadmap--please-help).

### Commercial and Production Deployments

This setup is great for getting started, but might not suitable for larger and more critical deployments. The good news is that you can seamlessly migrate to a redundant CouchDB cluster setup without changing anything else about your application.

If you’re faced with such a task and are unsure about factors like sharding, scaling, high availability etc., [we, Neighbourhoodie Software, are available for consulting and hands-on assistance](https://neighbourhood.ie/).

If you’ve already got a functioning CouchDB setup and would like it checked, we offer a [CouchDB Architecture Review](https://neighbourhood.ie/products-and-services/couchdb-architecture-review), where we inspect your setup and prepare a report with actionable suggestions for improvement, if necessary. Ongoing support retainers are also available!

You can also get your setup checked automatically with our [Opservatory service](https://opservatory.app/) and get a [SQL Query add-on](https://neighbourhood.ie/products-and-services/structured-query-server) to boot.

Please [get in touch with our lovely sales team](https://neighbourhood.ie/call) if you have any questions about commercial services. 👩‍💼 👨‍💼 

