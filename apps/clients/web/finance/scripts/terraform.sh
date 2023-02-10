#!/bin/sh

APP="finance"
APP_DIR="apps/clients/web/$APP"
TF="terraform -chdir=$APP_DIR"
SHA="$(git rev-parse --short HEAD)"
DEV_PROJECT_NAME="finance-development"
DEV_PROJECT_ID="finance-development-375914"
PROD_PROJECT_NAME="finance-production"
PROD_PROJECT_ID="finance-production-375914"

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

tf() {
    VARS="-var git_commit_sha=$SHA -var project_id=$1 -var project_name=$2"
    $TF init
    # echo "$TF plan $VARS"
    $TF plan $VARS
    $TF apply $VARS -auto-approve
}

case "$1" in
development) tf "$DEV_PROJECT_ID" "$DEV_PROJECT_NAME" ;;
production) tf "$PROD_PROJECT_ID" "$PROD_PROJECT_NAME" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
