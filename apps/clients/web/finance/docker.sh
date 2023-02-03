#!/bin/sh

HOST_CREDENTIALS_PATH="$HOME/.config/gcloud/landing-production-375914-153e51456a41.json"

APP_HOME="/app"
CONTAINER_CREDENTIALS_PATH="$APP_HOME/credentials.json"
DEVELOPMENT_PROJECT="finance-development-375914"
PRODUCTION_PROJECT="finance-production-375914"
APP="finance"
ARTIFACT_REGION="europe-west3"
REGISTRY="docker.pkg.dev"
IMAGE_NAME="web"
SHA=$(git rev-parse --short HEAD)
TAG="sha-$SHA"

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

run() {
    REPO="$ARTIFACT_REGION-$REGISTRY/$1/$APP"
    IMAGE="$REPO/$IMAGE_NAME"
    echo "docker run
        --device /dev/fuse
        --cap-add SYS_ADMIN
        -v $HOST_CREDENTIALS_PATH:$CONTAINER_CREDENTIALS_PATH:ro
        -e GOOGLE_APPLICATION_CREDENTIALS=$CONTAINER_CREDENTIALS_PATH
        $IMAGE:$TAG"
    docker run \
        --device /dev/fuse \
        --cap-add SYS_ADMIN \
        -v "$HOST_CREDENTIALS_PATH":"$CONTAINER_CREDENTIALS_PATH" \
        -e GOOGLE_APPLICATION_CREDENTIALS="$CONTAINER_CREDENTIALS_PATH" \
        -p 3000:3000 \
        "$IMAGE":"$TAG"
}

case "$1" in
    development) run "$DEVELOPMENT_PROJECT" ;;
    production) run "$PRODUCTION_PROJECT" ;;
    *) echo "Invalid configuration: $1" && exit 1 ;;
esac
