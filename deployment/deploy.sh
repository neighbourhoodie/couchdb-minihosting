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

echo "deploying $VERSION to $TARGET:$WEB_PATH/$VERSION"

# create remote dir
echo "create target dir"
ssh $TARGET mkdir $WEB_PATH/$VERSION

# tar
echo "tar up dir"
cp -r $DIR $VERSION
tar cj --exclude '._*' -f ./$DIR-$VERSION.tbz $VERSION

# copy to remote
echo "upload"
rsync --progress ./$DIR-$VERSION.tbz $TARGET:$WEB_PATH/

# untar
echo "untar on target $DIR-$VERSION.tbz"
ssh $TARGET "cd $WEB_PATH && tar xjf $DIR-$VERSION.tbz"

# swap symlink
echo "update symlink"
ssh $TARGET ln -fsT $WEB_PATH/$VERSION $WEB_PATH/latest

# delete older stuff
echo "cleanup"
rm -rf $VERSION $DIR-$VERSION.tbz
ssh $TARGET rm $WEB_PATH/$DIR-$VERSION.tbz
ssh $TARGET "find $WEB_PATH -maxdepth 1 -type d | sort | tail -n +2 | head -n -3 | xargs rm -rf"

echo "Done."
