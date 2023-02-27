#!/bin/bash
docker stop ui
docker stop interface
docker container prune -f
docker image rm interface
docker image rm ui
docker rmi $(docker images -f dangling=true -q)