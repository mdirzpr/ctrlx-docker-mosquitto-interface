docker container prune -f
docker image rm test
# docker buildx build --platform linux/arm64,linux/amd64 -t test .