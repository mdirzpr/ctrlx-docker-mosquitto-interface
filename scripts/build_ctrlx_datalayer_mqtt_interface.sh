#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

TARGET_ARCH=$1
echo TARGET_ARCH: ${TARGET_ARCH}
IMAGE_NAME2="ctrlx-datalayer-mqtt-interface"
IMAGE_TAG2="latest"
DOCKER_CLI="/snap/bin/docker"
echo --- add image env variables
echo IMAGE_NAME2=${IMAGE_NAME2} >> ../docker-compose/docker-compose.env
echo IMAGE_TAG2=${IMAGE_TAG2} >> ../docker-compose/docker-compose.env
echo --- create ctrlx-datalayer-mqtt-interface docker image with platform ${TARGET_ARCH}
${DOCKER_CLI} buildx build -f ../docker-compose/Dockerfile_interface --platform linux/${TARGET_ARCH} -t ${IMAGE_NAME2}:${IMAGE_TAG2} --output "type=docker,name=${IMAGE_NAME2}:${IMAGE_TAG2}" --build-context project=../ctrlx-datalayer-mqtt-interface  .
${DOCKER_CLI} save ${IMAGE_NAME2}:${IMAGE_TAG2} | gzip > ../docker-compose/image2.tar.gz
${DOCKER_CLI} rmi ${IMAGE_NAME2}:${IMAGE_TAG2}