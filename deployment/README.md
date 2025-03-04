# Deployment

This is a pair of scripts that allow you to easily deploy code from your dev machine, and roll back to the previous deployment in case your current one doesn’t work.

## Prerequisites

- The directory where the server is going to host the web app needs to already exist. By default, this is `/home/deploy/web`. It is automatically created by the install script in the root folder, by creating a `deploy` user with a corresponding user directory in `home`, and then adding a Docker volume used by nginx in `/web`. This directory maps to the `WEB_PATH` variable in the `deploy.env` file, and ideally, you won’t have to change it.
  
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
  sudo apt-get install -y rsync bzip2
  ```

### Add the deploy user’s `ssh` key to the server

The deploy user needs to be authorised to `ssh` into the host server. By default, `ssh` will attempt use your local default key to do this, this is usually something like `~/ssh/id_rsa`, but it depends. You can check which one is used by scanning through the verbose output of a connection attempt:

```sh
ssh -v deploy@YOUR_SERVER_IP_OR_DOMAIN_HERE
```

Look for a line with `Will attempt key:`, this will tell you which key to use. 

There are many ways to get a public key onto a server, this is one of the simplest. After you've completed the installation in the root of this repo:

1. On your machine, run `ssh-copy-id deploy@YOUR_SERVER_IP_OR_DOMAIN_HERE` and follow the instructions.
2. You should now be able to `ssh` into your server as the deploy user: `ssh deploy@YOUR_SERVER_IP_OR_DOMAIN_HERE`
3. If that works, the deploy script should work too. 

You are of course free to use a different key than your default key and transfer it in a different manner, but that would exceed the scope of this readme. 

## Setup

1. Copy the files in this folder into your repository. The `deploy.env` file and the two scripts need to be placed at the same level.

    ```
2. Modify the `deploy.env` with your values.
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

> [!NOTE]
> Note that a rollback leaves the previous deploy directory on the server so you can inspect what goes wrong. If you don’t need it, delate it manually, so that after your next deploy, a further rollback does not get you the first rolled-back-from directory set up again.

## Troubleshooting

- `tar (child): bzip2: Cannot exec: No such file or directory`: You don’t have `bzip2` installed, see prerequisites above.
