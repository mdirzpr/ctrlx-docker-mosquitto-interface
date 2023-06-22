#!/bin/bash
./scripts/docker_clean.sh
docker buildx build -f ./docker-compose/v6111_x64.Dockerfile --platform linux/amd64 -t "secomea:latest" --output "type=docker,name=secomea:latest" ./docker-compose