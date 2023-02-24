#!/bin/bash
TARGET_ARCH=$1
echo TARGET_ARCH: ${TARGET_ARCH}
IMAGE_NAME2="ctrlx-datalayer-mqtt-plc"
IMAGE_TAG2="latest"
DOCKER_CLI="/snap/bin/docker"
echo --- add image env variables
echo IMAGE_NAME2=${IMAGE_NAME2} >> ./docker-compose/docker-compose.env
echo IMAGE_TAG2=${IMAGE_TAG2} >> ./docker-compose/docker-compose.env
echo --- create ctrlx-datalayer-mqtt-plc docker image with platform ${TARGET_ARCH}
${DOCKER_CLI} buildx build --platform linux/${TARGET_ARCH} -t ${IMAGE_NAME2}:${IMAGE_TAG2} --output "type=docker,name=${IMAGE_NAME2}:${IMAGE_TAG2}" .
# ${DOCKER_CLI} build -t ${IMAGE_NAME2}:${IMAGE_TAG2} .
${DOCKER_CLI} save ${IMAGE_NAME2}:${IMAGE_TAG2} | gzip > ./docker-compose/image2.tar.gz
${DOCKER_CLI} rmi ${IMAGE_NAME2}:${IMAGE_TAG2}