#!/bin/bash

set -e

APPIMAGE_BASENAME="pea-soup-linux-x86_64.AppImage"
IMG_NAME="pea-soup.linux.docker-img"
CONTAINER_NAME="pea-soup-linux-builder"

docker buildx build -f Dockerfile.linux -t "$IMG_NAME" ./
docker run --name "$CONTAINER_NAME" "$IMG_NAME"

echo 'Extracting AppImage to CWD...'
mkdir -p ./dist/
docker cp "$CONTAINER_NAME:/workspace/dist/$APPIMAGE_BASENAME" ./dist/

sudo chown -R $SUDO_USER:$SUDO_USER ./dist/

echo 'Cleaning up Docker container...'
docker rm "$CONTAINER_NAME"

echo 'Done.'
