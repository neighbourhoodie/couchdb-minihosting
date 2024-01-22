#!/bin/bash
set -e

if [ ! -f deploy.env ]; then
  echo "Error. Could not find deploy.env file! Exiting."
  exit 1
fi

set -a
source deploy.env
set +a

echo "Looking for symlink $WEB_PATH/latest"
LATEST_EXISTS=$(ssh "$TARGET" "[ -h \"$WEB_PATH/latest\" ] && echo 'exists' || echo 'not exists'")

if [ "$LATEST_EXISTS" = "not exists" ]; then
  echo "Error: $WEB_PATH/latest symlink does not exist on the remote server. Exiting."
  exit 1
fi

CURRENT_LATEST=$(ssh "$TARGET" readlink -f "$WEB_PATH/latest")

# List all DIRECTORIES in alphabetical order
DIRECTORIES=$(ssh "$TARGET" find "$WEB_PATH" -maxdepth 1 -type d | sort)
DIRECTORIES_ARRAY=($DIRECTORIES)

# Find the index of the supplied folder
FOLDER_INDEX=0

for ((i=0; i<${#DIRECTORIES_ARRAY[@]}; i++)); do
  if [ "${DIRECTORIES_ARRAY[$i]}" == "$CURRENT_LATEST" ]; then
    FOLDER_INDEX=$i
    break
  fi
done

if [ "$FOLDER_INDEX" -le "1" ]; then
  echo "Error. Can't rollback: there are no more previous versions to revert to. Exiting."
  exit 1
fi

# Get the previous folder
PREVIOUS_FOLDER_INDEX=$((FOLDER_INDEX - 1))
PREVIOUS_FOLDER=${DIRECTORIES_ARRAY[$PREVIOUS_FOLDER_INDEX]}

echo "Changing /latest symlink from $CURRENT_LATEST to $PREVIOUS_FOLDER."

ssh "$TARGET" "cd $WEB_PATH && ln -fsT $PREVIOUS_FOLDER $WEB_PATH/latest"

echo "Done."
