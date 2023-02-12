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
    export TF_IN_AUTOMATION=true
    SHA="$(git rev-parse --short HEAD)"
    if grep -q "local" "$BACKEND"; then
        $TF init
        $TF plan -target="module.$APP" -out="$PLAN" -input=false -lock-timeout=60s -var=git_commit_sha="$SHA"
        $TF apply -input=false -auto-approve -lock-timeout=60s $PLAN
        sed -i 's/local/gcs/g' "$BACKEND"
        echo "Migrating state"
        echo "yes" | $TF init -migrate-state -backend-config="bucket=$APP-$1-state"
    else
        $TF init -backend-config="bucket=$APP-$1-state"
        $TF plan -target="module.$APP" -out="$PLAN" -input=false -lock-timeout=60s -var=git_commit_sha="$SHA"
        $TF apply -input=false -auto-approve -lock-timeout=60s $PLAN
    fi
    rm "$TF_DIR/$PLAN"
}

case "$1" in
development) tf "$1" ;;
production) tf "$1" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
