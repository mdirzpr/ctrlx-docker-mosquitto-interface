docker container prune -f
docker image rm test
docker rmi $(docker images -f dangling=true -q)
# docker buildx build --platform linux/arm64,linux/amd64 -t test .