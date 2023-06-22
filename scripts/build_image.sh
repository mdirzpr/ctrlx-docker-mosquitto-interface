#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

TARGET_ARCH=$1
echo TARGET_ARCH: ${TARGET_ARCH}
IMAGE_NAME="ctrlx-secomea"
IMAGE_TAG="latest"
DOCKER_CLI="/snap/bin/docker"
echo --- add image env variables
rm ../docker-compose/docker-compose.env
echo IMAGE_NAME=${IMAGE_NAME} >> ../docker-compose/docker-compose.env
echo IMAGE_TAG=${IMAGE_TAG} >> ../docker-compose/docker-compose.env
echo --- create ctrlx-secomea docker image with platform ${TARGET_ARCH}
${DOCKER_CLI} buildx build -f ../docker-compose/v6142_AARCH64.Dockerfile --platform linux/${TARGET_ARCH} -t ${IMAGE_NAME}:${IMAGE_TAG} --output "type=docker,name=${IMAGE_NAME}:${IMAGE_TAG}" ../docker-compose
${DOCKER_CLI} save ${IMAGE_NAME}:${IMAGE_TAG} | gzip > ../docker-compose/image.tar.gz
${DOCKER_CLI} rmi ${IMAGE_NAME}:${IMAGE_TAG}