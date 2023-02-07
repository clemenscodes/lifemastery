#!/bin/sh
set -e
DEVELOPMENT_PROJECT="finance-development-375914"
PRODUCTION_PROJECT="finance-production-375914"

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

upload_assets_to_cdn() {
    PROJECT_ID="$1"
    set_project "$PROJECT_ID"
    upload_static
    upload_public
}

set_project() {
    echo "Setting project to $PROJECT_ID"
    gcloud config set project "$PROJECT_ID"
    FULL_BUCKET_ADDRESS="$(gsutil ls | grep cdn)"
    BUCKET="$(echo "$FULL_BUCKET_ADDRESS" | awk -F '/' '{print $3}')"
    BUCKET_ADDRESS="gs://$BUCKET"
    PUBLIC="dist/apps/clients/web/finance/public"
    PUBLIC_BUCKET_ADDRESS="$BUCKET_ADDRESS/public"
    STATIC="dist/apps/clients/web/finance/.next/static"
    STATIC_BUCKET_ADDRESS="$BUCKET_ADDRESS/_next/static/"
}

upload_static() {
    echo "Uploading static assets to $STATIC_BUCKET_ADDRESS"
    gsutil -m rsync -u -r "$STATIC" "$STATIC_BUCKET_ADDRESS"
}

upload_public() {
    echo "Uploading public assets to $PUBLIC_BUCKET_ADDRESS"
    gsutil -m rsync -u -r "$PUBLIC" "$PUBLIC_BUCKET_ADDRESS/"
}

case "$1" in
    development) upload_assets_to_cdn "$DEVELOPMENT_PROJECT" ;;
    production) upload_assets_to_cdn "$PRODUCTION_PROJECT" ;;
    *) echo "Invalid configuration: $1" && exit 1 ;;
esac
