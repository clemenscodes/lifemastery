#!/bin/sh

set -e

APP="finance"
DEVELOPMENT_PROJECT="finance-development-375914"
PRODUCTION_PROJECT="finance-production-375914"
APP_DIR="apps/clients/web/$APP"
PLAN="plan.tfplan"
ARTIFACT_REGION="europe-west3"
REGISTRY="docker.pkg.dev"
IMAGE_NAME="web"

export TF_IN_AUTOMATION=true

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

tf() {
    TF_DIR="$APP_DIR/infra/$1"
    TF="terraform -chdir=$TF_DIR"
    BACKEND="$TF_DIR/backend.tf"
    SHA="$(git rev-parse --short HEAD)"
    REPO="$ARTIFACT_REGION-$REGISTRY/$2/$APP"
    IMAGE="$REPO/$IMAGE_NAME"
    TAGGED_IMAGE="$IMAGE:$SHA"
    BACKEND_CONFIG="-backend-config=bucket=$APP-$1-state"
    DEFAULT_PLAN="-out=$PLAN -input=false -lock-timeout=60s -lock=false -var=git_commit_sha=$SHA"
    ARTIFACT_PLAN="-target=module.$APP $DEFAULT_PLAN"
    APPLY_ARGS="-input=false -auto-approve -lock=false -lock-timeout=60s $PLAN"
    if grep -q "local" "$BACKEND"; then
        $TF init
        $TF plan $ARTIFACT_PLAN
        $TF apply $APPLY_ARGS
        echo "Pushing image to Cloud Run"
        docker push "$TAGGED_IMAGE"
        $TF init
        $TF plan $DEFAULT_PLAN
        $TF apply $APPLY_ARGS
        sed -i 's/local/gcs/g' $BACKEND
        echo "Migrating state"
        echo "yes" | $TF init $BACKEND_CONFIG
    else
        $TF init $BACKEND_CONFIG
        $TF plan $ARTIFACT_PLAN
        $TF apply $APPLY_ARGS
        echo "Pushing image to Cloud Run"
        docker push "$TAGGED_IMAGE"
        $TF init $BACKEND_CONFIG
        $TF plan $DEFAULT_PLAN
        $TF apply $APPLY_ARGS
    fi
    rm "$TF_DIR/$PLAN"
}

case "$1" in
development) tf "$1" "$DEVELOPMENT_PROJECT" ;;
production) tf "$1" "$PRODUCTION_PROJECT" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
