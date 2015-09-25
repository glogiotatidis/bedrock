#!/bin/bash
#
set -ex
DOCKER_IMAGE_TAG=${DOCKER_REPOSITORY}:${GIT_COMMIT}

# If docker image exists and no force rebuild do nothing
FORCE_REBUILD=`echo "$FORCE_REBUILD" | tr '[:upper:]' '[:lower:]'`
if [[ $FORCE_REBUILD != "true" ]];
then
    if docker history -q $DOCKER_IMAGE_TAG 2> /dev/null;
    then
        echo "Docker image already exists, do nothing"
        exit 0;
    fi
fi

# Workaround to ignore mtime until we upgrade to Docker 1.8
# See https://github.com/docker/docker/pull/12031
find . -newerat 20140101 -exec touch -t 201401010000 {} \;

cat docker/dockerfiles/${DOCKERFILE} | envsubst > Dockerfile
docker build -t $DOCKER_IMAGE_TAG .

docker save $DOCKER_IMAGE_TAG  | sudo docker-squash -t $DOCKER_IMAGE_TAG | docker load
