TODO:
- make domain configurable in haproxy
- letsencrypt folder permissions: moiunt :ro
- map port 80 to just nginx/well known
- set up certbot container for renewals
- post startup script that creates _users and _replicator
- move couch credentials in to .env file



Usage:
- (TODO): create .env file

- sudo docker run -it --rm  -p 80:80 -p 443:443 --name certbot             -v "/etc/letsencrypt:/etc/letsencrypt"             -v "/var/lib/letsencrypt:/var/lib/letsencrypt"             certbot/certbot certonly --standalone -d mini.backend.lol --email jan@neigbourhood.ie --agree-tos --keep --non-interactive
  - wrap this in a shell script that sources .env
  - chmod -R go+rx /etc/letsencrypt/ so we can map them into haproxy
    - maybe map these all into ./
- docker-compose up -d



Final imagined usage:

# set up vps
# set up dns
git clone nh/mini
cd mini
emacs .env
./run.sh
  - sets up certbot cronjob or self-update



