#!/bin/bash
./scripts/docker_clean.sh
docker buildx build -f ./docker-compose/Dockerfile_interface --platform linux/amd64 -t "interface:latest" --output "type=docker,name=interface:latest" --build-context project=./ctrlx-datalayer-mqtt-interface  .
docker buildx build -f ./docker-compose/Dockerfile_ui --platform linux/amd64 -t "ui:latest" --output "type=docker,name=ui:latest" --build-context project=./ctrlx-datalayer-mqtt-ui  .