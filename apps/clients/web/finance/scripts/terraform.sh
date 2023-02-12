#!/bin/sh
set -e
APP="finance"
APP_DIR="apps/clients/web/$APP"
PLAN="plan.tfplan"

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

tf() {
    TF_DIR="$APP_DIR/infra/$1"
    TF="terraform -chdir=$TF_DIR"
    BACKEND="$TF_DIR/backend.tf"
    # SHA="$(git rev-parse --short HEAD)"
    if grep -q "local" "$BACKEND"; then
        $TF init
        $TF plan -out="$PLAN" # -var git_commit_sha="$SHA"
        $TF apply $PLAN
        sed -i 's/local/gcs/g' "$BACKEND"
        echo "Migrating state"
        echo "yes" | $TF init -migrate-state -backend-config="bucket=$APP-$1-state"
    else
        $TF init -backend-config="bucket=$APP-$1-state"
        $TF plan -out="$PLAN" # -var git_commit_sha="$SHA"
        $TF apply $PLAN
    fi
    rm "$TF_DIR/$PLAN"
}

case "$1" in
development) tf "$1" ;;
production) tf "$1" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
