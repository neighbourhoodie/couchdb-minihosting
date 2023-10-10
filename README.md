TODO:
- [x] make domain configurable in haproxy
- [ ] letsencrypt folder permissions: moiunt :ro
- [ ] map port 80 to just nginx/well known
- [ ] set up certbot container for renewals
- [x] post startup script that creates _users and _replicator
- [x] move couch credentials in to .env file
- [ ] set up certbot cronjob or self-update

Usage:
- sudo docker run -it --rm  -p 80:80 -p 443:443 --name certbot             -v "/etc/letsencrypt:/etc/letsencrypt"             -v "/var/lib/letsencrypt:/var/lib/letsencrypt"             certbot/certbot certonly --standalone -d mini.backend.lol --email jan@neigbourhood.ie --agree-tos --keep --non-interactive
  - wrap this in a shell script that sources .env
  - chmod -R go+rx /etc/letsencrypt/ so we can map them into haproxy
    - maybe map these all into ./
- docker-compose up -d

# Final imagined usage:

# set up vps

# set up dns

# Steps

Clone the repository
```sh
git clone couchdb-mini-hosting
git clone git@github.com:neighbourhoodie/couchdb-mini-hosting.git

# or via HTTP
# git clone https://github.com/neighbourhoodie/couchdb-mini-hosting.git
```

Enter to the folder
```sh
cd couchdb-mini-hosting
```

Modify the environment variables with your values
```sh
nano .env
```

Run `start.sh` script
```sh
./start.sh
```

Start the services
```sh
docker-compose up -d
```

Finish running the `post-install.sh` script
```sh
./post-install.sh
```



