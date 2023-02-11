#!/bin/sh

APP="finance"
APP_DIR="apps/clients/web/$APP"
TF="terraform -chdir=$APP_DIR"
SHA="$(git rev-parse --short HEAD)"
PLAN="plan.out"

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

tf() {
    $TF workspace select "$1"
    $TF init
    $TF plan -var-file="$1".tfvars -var git_commit_sha="$SHA" -out=$PLAN
    $TF apply $PLAN
    rm "$APP_DIR/$PLAN"
}

case "$1" in
development) tf "$1" ;;
production) tf "$1" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
