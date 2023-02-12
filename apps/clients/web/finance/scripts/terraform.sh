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
    sed -i 's/gcs/local/g' "$BACKEND"
    # SHA="$(git rev-parse --short HEAD)"
    $TF init -reconfigure
    $TF plan -out="$PLAN" # -var git_commit_sha="$SHA"
    $TF apply $PLAN
    BACKEND_BUCKET_SERVICE_ACCOUNT=$($TF output bucket_service_account | tr -d '"')
    BACKEND_BUCKET_NAME=$($TF output bucket_name | tr -d '"')
    sed -i 's/local/gcs/g' "$BACKEND"
    echo "Migrating state"
    echo "yes" | $TF init -migrate-state \
        -backend-config="bucket=$BACKEND_BUCKET_NAME"
    sed -i 's/gcs/local/g' "$BACKEND"
    rm "$TF_DIR/$PLAN"
}

case "$1" in
development) tf "$1" ;;
production) tf "$1" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
