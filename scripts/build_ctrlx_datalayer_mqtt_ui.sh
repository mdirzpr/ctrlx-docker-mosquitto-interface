#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

TARGET_ARCH=$1
echo TARGET_ARCH: ${TARGET_ARCH}
IMAGE_NAME3="ctrlx-datalayer-mqtt-ui"
IMAGE_TAG3="latest"
DOCKER_CLI=$(which docker)
echo --- add image env variables
echo IMAGE_NAME3=${IMAGE_NAME3} >> ../docker-compose/docker-compose.env
echo IMAGE_TAG3=${IMAGE_TAG3} >> ../docker-compose/docker-compose.env
echo --- create ctrlx-datalayer-mqtt-ui docker image with platform ${TARGET_ARCH}
${DOCKER_CLI} buildx build -f ../docker-compose/Dockerfile_ui --platform linux/${TARGET_ARCH} -t ${IMAGE_NAME3}:${IMAGE_TAG3} --output "type=docker,name=${IMAGE_NAME3}:${IMAGE_TAG3}" --build-context project=../ctrlx-datalayer-mqtt-ui .
${DOCKER_CLI} save ${IMAGE_NAME3}:${IMAGE_TAG3} | gzip > ../docker-compose/image3.tar.gz
${DOCKER_CLI} rmi ${IMAGE_NAME3}:${IMAGE_TAG3}
