#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

TARGET_ARCH=$1
echo TARGET_ARCH: ${TARGET_ARCH}
IMAGE_NAME="eclipse-mosquitto"
IMAGE_TAG="latest"
DOCKER_CLI="/snap/bin/docker"
echo --- create ../docker-compose/docker-compose.env
rm -v -f ../docker-compose/docker-compose.env
echo IMAGE_NAME=${IMAGE_NAME} >> ../docker-compose/docker-compose.env
echo IMAGE_TAG=${IMAGE_TAG} >> ../docker-compose/docker-compose.env
echo --- create docker image with platform ${TARGET_ARCH}
rm -f -v ../docker-compose/*.tar
${DOCKER_CLI} pull ${IMAGE_NAME}:${IMAGE_TAG} --platform ${TARGET_ARCH}
${DOCKER_CLI} save ${IMAGE_NAME}:${IMAGE_TAG} | gzip > ../docker-compose/image.tar.gz
${DOCKER_CLI} rmi ${IMAGE_NAME}:${IMAGE_TAG}