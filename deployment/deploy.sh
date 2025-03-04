#!/bin/bash

set -e

if [ ! -f deploy.env ]; then
  echo "Error. Could not find deploy.env file! Exiting"
  exit 1
fi

# deploy timestamp
VERSION=$(date "+%Y%m%d%H%M%S")

set -a
source deploy.env
set +a

APPNAME=`basename $DIR`

echo "deploying $VERSION to $TARGET:$WEB_PATH/$VERSION"

# Check if rsync exists here
if ! command -v rsync >/dev/null 2>&1; then
  echo "Error: rsync is not installed on this machine. Please install it and try again."
  exit 1
fi

# Check if bzip exists there
if ! ssh "$TARGET" "command -v bzip2 >/dev/null 2>&1"; then
  echo "Error: bzip2 is not installed on $TARGET. Please install it and try again."
  exit 1
fi

# create remote dir
echo "create target dir"
ssh $TARGET mkdir -p $WEB_PATH/$VERSION

# tar
echo "tar up dir"
cp -r $DIR $VERSION
tar cj --exclude '._*' -f ./$APPNAME-$VERSION.tbz $VERSION

# copy to remote
echo "upload"
rsync --progress ./$APPNAME-$VERSION.tbz $TARGET:$WEB_PATH/

# untar
echo "untar on target $DIR-$VERSION.tbz"
ssh $TARGET "cd $WEB_PATH && tar xjf $APPNAME-$VERSION.tbz"

# swap symlink
echo "update symlink"
ssh $TARGET ln -fsT $WEB_PATH/$VERSION $WEB_PATH/latest

# delete older stuff
echo "cleanup"
rm -rf $VERSION $APPNAME-$VERSION.tbz
ssh $TARGET rm $WEB_PATH/$DIR-$VERSION.tbz
ssh $TARGET "find $WEB_PATH -maxdepth 1 -type d | sort | tail -n +2 | head -n -3 | xargs rm -rf"

echo "Done."
