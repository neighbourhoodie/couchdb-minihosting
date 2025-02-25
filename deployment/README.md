# Deployment

## Prerequisites

- The directory where the deployment is going to host the web app needs to already exist. It is automatically created by the setup scripts in the root folder, by creating a `deploy` user with a corresponding user directory in `home`. This directory maps to the `WEB_PATH` variable in the `deploy.env` file, ideally, you won’t have to change it.
  
- The server requires the following software to be installed:
  - `rysnc`
  - `bzip2`

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

## Setup

- Copy the files in this folder into your repository. The `deploy.env` file and the two scripts need to be placed at the same level.
- Give executable permissions to the scripts:
```sh
chmod +x deploy.sh rollback.sh
```
- Modify the `deploy.env` with your values.

- *WEB_PATH*: The folder on the server you want to deploy to. Should probably be left as `/home/deploy/web`.
- *TARGET*: The ssh target, should be `deploy@your.domain`, eg. `deploy@backend.lol`.
- *DIR*: The directory you want to deploy. This is probably your `dist` or `build` folder.

## Deploy

The `deploy.sh` script will create a 

To execute the script, run
```sh
./deploy.sh
```

## Rollback

To execute the script, run
```sh
./rollback.sh
```

