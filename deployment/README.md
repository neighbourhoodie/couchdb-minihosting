# Deployment

This is a pair of scripts that allow you to easily deploy code from your dev machine, and roll back to the previous deployment in case your current one doesn’t work.

## Prerequisites

- The directory where the server is going to host the web app needs to already exist. By default, this is `/home/deploy/web`. It is automatically created by the setup scripts in the root folder, by creating a `deploy` user with a corresponding user directory in `home`, and then adding a Docker volume used by nginx in `/web`. This directory maps to the `WEB_PATH` variable in the `deploy.env` file, and ideally, you won’t have to change it.
  
- ⚠️ The script **requires** two pieces of software:
  - `rysnc` must exist on the machine _from_ which you are deploying
  - `bzip2` must exist on the server _to_ which you are deploying

  The script will check if these are present. If you want to do this manually:

  You can check if those are present with:
  ```sh
  which rsync
  which bzip2
  ```

  If you are on a Linux distribution, these can be installed with:
  ```sh
  sudo apt-get install rsync
  sudo apt-get install bzip2
  ```

### Add the deploy user’s `ssh` key to the server

The deploy user needs to be authorised to `ssh` into the host server. By default, `ssh` will attempt use your local default key to do this, this is usually something like `./ssh/id_rsa`, but it depends. You can check which one is used by scanning through the verbose output of a connection attempt:

```sh
ssh -v deploy@YOUR_SERVER_IP_OR_DOMAIN_HERE
```

Look for a line with `Will attempt key:`, this will tell you which key to use. 

There are many ways to get a public key onto a server, this is one of the simplest. After you've completed the installation in the root of this repo:

1. `ssh` in to the server with your root account: `ssh root@YOUR_SERVER_IP_OR_DOMAIN_HERE`
2. Go to the deploy user’s home folder: `cd /home/deploy`
3. If there is no `.ssh` folder here, make one: `mkdir -p .ssh`
4. Back on your local system (the one you want to deploy _from_), get the **PUBLIC** part of the key `ssh` told you about earlier. Go to your `~/.ssh` folder and view that key, e.g. with: `cat id_rsa.pub`. **The `.pub` suffix denotes that this is the public part of the key**. This is important: only the public part of the key pair may ever leave your local system (that’s why it’s called "public"). Make very sure you’re not accidentally making the private part of your key pair public. If the output contains `-----BEGIN RSA PRIVATE KEY-----`, **that’s the wrong one**. The public key looks something like this:
    ```sh
    ssh-rsa AAAAB3N…fairly_long_string…K1bl0rQ== probably@your-email-address.com
    ```
5. Copy the public key and switch back to the tab with your `ssh` session to the server
6. In the `/home/deploy/.ssh` folder you just made in step 3, paste the public key into the `authorized_keys` file like this:
    ```sh
    echo PASTE_YOUR_PUBLIC_KEY_HERE >> authorized_keys
7. You should now be able to `ssh` into your server as the deploy user: `ssh deploy@YOUR_SERVER_IP_OR_DOMAIN_HERE`
8. If that works, the deploy script should work too. 

You are of course free to use a different key than your default key and transfer it in a different manner, but that would exceed the scope of this readme. 

## Setup

1. Copy the files in this folder into your repository. The `deploy.env` file and the two scripts need to be placed at the same level.
2. Give executable permissions to the scripts:
    ```sh
    chmod +x deploy.sh rollback.sh
    ```
3. Modify the `deploy.env` with your values.
   - `WEB_PATH`: The folder on the server you want to deploy to. Should probably be left as `/home/deploy/web`.
   - `TARGET`: The ssh target, should be `deploy@your.domain`, eg. `deploy@backend.lol`.
   - `DIR`: The directory you want to deploy. This is probably your `dist` or `build` folder.

## Deploy

To deploy the current state of the folder specified by the `DIR` var:
```sh
./deploy.sh
```

## Rollback

The deploy script keeps the last three deployments on the server so you can quickly roll back to the previous state in case you’ve deployed something that doesn’t work.

To rollback to the previous deployment, run:
```sh
./rollback.sh
```

## Troubleshooting

- `tar (child): bzip2: Cannot exec: No such file or directory`: You don’t have `bzip2` installed, see prerequisites above.