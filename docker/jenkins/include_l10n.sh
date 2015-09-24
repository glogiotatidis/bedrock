#!/bin/bash
# Needs DOCKER_REPOSITORY and FROM_DOCKER_REPOSITORY
#
# To set them go to Job -> Configure -> Build Environment -> Inject
# passwords and Inject env variables
#
set -xe

DOCKER_IMAGE_TAG=${DOCKER_REPOSITORY}:${GIT_COMMIT}

# Used to trigger downstream Jenkins jobs
TRIGGER_FILE=.docker-updated
rm -rf $TRIGGER_FILE

if [[ $BUILD_CAUSE == "TIMERTRIGGER" ]]
then
    SVN_STATUS=`svn status -uq locale | wc -l`
    if [[ $SVN_STATUS == "0" ]]
    then
        # No updates, just exit
        echo "No locale updates"
        exit 0;
    fi
fi

touch $TRIGGER_FILE

set +e
svn cleanup locale
set -e
svn co http://svn.mozilla.org/projects/mozilla.com/trunk/locales/ locale


cat docker/dockerfiles/bedrock_l10n | envsubst > ./locale/Dockerfile
echo ".svn" > ./locale/.dockerignore

docker build -f locale/Dockerfile -t $DOCKER_IMAGE_TAG locale
