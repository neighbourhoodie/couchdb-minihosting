# Deployment

This is a pair of scripts that allow you to easily deploy code from your dev machine, and roll back to the previous deployment in case your current one doesn’t work.

## Prerequisites

1. The directory where the server is going to host the web app needs to already exist. By default, this is `/home/deploy/web`. It is automatically created by the install script in the root folder, by creating a `deploy` user with a corresponding user directory in `home`, and then adding a Docker volume used by nginx in `/web`. This directory maps to the `WEB_PATH` variable in the `deploy.env` file, and ideally, you won’t have to change it.
  
2. > [!IMPORTANT]
   > The script **requires** two pieces of software:
   >  - `rysnc` must exist on the machine _**from**_ which you are deploying
   >  - `bzip2` must exist on the server _**to**_ which you are deploying

    The script will check if these are present and warn you if not.

    If you want to do this check manually:
    ```sh
    # On the dev machine:
    which rsync
    # On the server:
    which bzip2
    ```

    **Installing rsync and bzip2**

    - **rsync**: If your dev machine runs MacOS, `rsync` is already installed. On a Linux system, you can install it with:
        ```sh
        sudo apt-get install -y rsync
        ```

    - **bzip2**: On your Linux server, `bzip2` can be installed with:
       ```sh
       sudo apt-get install -y bzip2
       ```

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
