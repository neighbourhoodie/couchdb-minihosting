# Deployment

## Prerequisites

- The directory where the deployment is going to host the web app needs to be created beforehand. This directory will be added to the `deploy.env` environment file to the `WEB_PATH` variable.
- The server requires the following software installed:
  - `rysnc`
  - `bzip2`

You can check if those are already installed with
```sh
which rsync
```

If you are on a linux distribution, these can be installed like
```sh
sudo apt-get install rsync
```

## Set up

- Copy the files into your repository. The `deploy.env` file and the scripts need to be placed at the same level.
- Give executable permissions to the scripts:
```sh
chmod +x deploy.sh rollback.sh
```
- Modify the `deploy.env` with your values.

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

