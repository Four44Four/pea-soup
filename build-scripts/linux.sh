#!/bin/bash

set -e

IMG_NAME="pea-soup.linux.docker-img"
CONTAINER_NAME="pea-soup-linux-builder"

docker buildx build -f Dockerfile.linux -t "$IMG_NAME" ./
docker run --name "$CONTAINER_NAME" "$IMG_NAME"

echo 'Extracting AppImage to CWD...'
docker cp "$CONTAINER_NAME:/workspace/dist/$APPIMAGE_BASENAME" ./

echo 'Cleaning up Docker container...'
docker rm "$CONTAINER_NAME"

echo 'Done.'
