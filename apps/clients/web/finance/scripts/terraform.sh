#!/bin/sh
set -e
APP="finance"
APP_DIR="apps/clients/web/$APP"
TF_DIR="$APP_DIR/infra"
TF="terraform -chdir=$TF_DIR"
SHA="$(git rev-parse --short HEAD)"
PLAN="plan.tfplan"

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

tf() {
    $TF workspace select "$1"
    # $TF init -reconfigure -backend-config="bucket=finance-$1-state"
    $TF init
    $TF plan -var git_commit_sha="$SHA" -out=$PLAN
    # $TF apply $PLAN
    rm "$TF_DIR/$PLAN"
}

case "$1" in
development) tf "$1" ;;
production) tf "$1" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
