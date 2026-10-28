#!/bin/bash

set -e

ZIP_BASENAME="pea-soup-windows-x64.zip"
IMG_NAME="pea-soup.windows.docker-img"
CONTAINER_NAME="pea-soup-windows-builder"

docker buildx build -f Dockerfile.windows -t "$IMG_NAME" ./
docker run --name "$CONTAINER_NAME" "$IMG_NAME"

echo 'Extracting ZIP package to CWD...'
mkdir -p ./dist/
docker cp "$CONTAINER_NAME:/workspace/dist/$ZIP_BASENAME" ./dist/

sudo chown -R $SUDO_USER:$SUDO_USER ./dist/

echo 'Cleaning up Docker container...'
docker rm "$CONTAINER_NAME"

echo 'Done.'
