#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

docker stop ui
docker stop interface
docker container prune -f
docker image rm interface
docker image rm ui
docker rmi $(docker images -f dangling=true -q)