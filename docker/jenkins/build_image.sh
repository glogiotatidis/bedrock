#!/bin/bash
#
set -ex

# TODO comment
find . -newerat 20140101 -exec touch -t 201401010000 {} \;

cat docker/dockerfiles/${DOCKERFILE} | envsubst > Dockerfile
DOCKER_IMAGE_TAG=${DOCKER_REPOSITORY}:${GIT_COMMIT}
docker build -t $DOCKER_IMAGE_TAG .

docker save $DOCKER_IMAGE_TAG  | sudo docker-squash -t $DOCKER_IMAGE_TAG | docker load
