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
PURPLE="\\033[0;35m"
SET="\\033[0m\\n"

export TF_IN_AUTOMATION=true

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

tf() {
    CONFIG="$1"
    PROJECT="$2"
    TF_DIR="$APP_DIR/infra/$CONFIG"
    TF="terraform -chdir=$TF_DIR"
    BACKEND="$TF_DIR/backend.tf"

    SHA="$(git rev-parse --short HEAD)"

    REPO="$ARTIFACT_REGION-$REGISTRY/$PROJECT/$APP"
    IMAGE="$REPO/$IMAGE_NAME"
    TAGGED_IMAGE="$IMAGE:$SHA"

    BACKEND_CONFIG="-backend-config=bucket=$APP-$CONFIG-state"

    PLAN_ARG="-out=$PLAN"
    INPUT_ARG="-input=false"
    LOCK_ARG="-lock=false"
    LOCK_TIMEOUT_ARG="-lock-timeout=60s"
    VAR_ARG="-var=git_commit_sha=$SHA"
    TARGET_ARG="-target=module.$APP"
    APPROVE_ARG="-auto-approve"

    DEFAULT_PLAN="$PLAN_ARG $INPUT_ARG $LOCK_TIMEOUT_ARG $LOCK_ARG $VAR_ARG"
    ARTIFACT_PLAN="$TARGET_ARG $DEFAULT_PLAN"

    APPLY_ARGS="$INPUT_ARG $APPROVE_ARG $LOCK_ARG $LOCK_TIMEOUT_ARG $PLAN"

    if grep -q "local" "$BACKEND"; then
        local_plan
    else
        remote_plan
    fi
    rm "$TF_DIR/$PLAN"
}

local_plan() {
    $TF init
    artifact_plan
    push_image
    $TF init
    default_plan
    sed -i 's/local/gcs/g' "$BACKEND"
    echo "Migrating state"
    echo "yes" | $TF init "$BACKEND_CONFIG"
}

remote_plan() {
    $TF init "$BACKEND_CONFIG"
    artifact_plan
    push_image
    $TF init "$BACKEND_CONFIG"
    default_plan
}

artifact_plan() {
    TF_COMMAND="$TF plan $ARTIFACT_PLAN"
    run_tf_command
    TF_COMMAND="$TF apply $APPLY_ARGS"
    run_tf_command
}

default_plan() {
    TF_COMMAND="$TF plan $DEFAULT_PLAN"
    run_tf_command
    TF_COMMAND="$TF apply $APPLY_ARGS"
    run_tf_command
}

run_tf_command() {
    # echo
    # purple "$TF_COMMAND"
    # echo
    eval "$TF_COMMAND"
}

push_image() {
    echo "Pushing image $TAGGED_IMAGE to Cloud Run"
    docker push "$TAGGED_IMAGE"
}

purple() {
    printf "$PURPLE%s$SET" "$1"
}

case "$1" in
development) tf "$1" "$DEVELOPMENT_PROJECT" ;;
production) tf "$1" "$PRODUCTION_PROJECT" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
