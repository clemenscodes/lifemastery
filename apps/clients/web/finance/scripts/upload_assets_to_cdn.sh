#!/bin/sh

DEVELOPMENT_PROJECT="finance-development-375914"
PRODUCTION_PROJECT="finance-production-375914"
APP="finance"
APP_DIR="apps/clients/web/$APP"
PUBLIC="dist/$APP_DIR/public"
STATIC="dist/$APP_DIR/.next/static"

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

upload_assets_to_cdn() {
    PROJECT_ID="$1"
    BUCKETS="$(gsutil ls -p "$PROJECT_ID")"
    echo "Buckets: $BUCKETS"
    FULL_BUCKET_ADDRESS="$(echo "$BUCKETS" | grep cdn)"
    echo "Full: $FULL_BUCKET_ADDRESS"
    BUCKET="$(echo "$FULL_BUCKET_ADDRESS" | awk -F '/' '{print $3}')"
    echo "Bucket: $BUCKET"
    BUCKET_ADDRESS="gs://$BUCKET"
    echo "Bucket address: $BUCKET_ADDRESS"
    PUBLIC_BUCKET_ADDRESS="$BUCKET_ADDRESS/public"
    echo "Public: $PUBLIC_BUCKET_ADDRESS"
    STATIC_BUCKET_ADDRESS="$BUCKET_ADDRESS/_next/static/"
    echo "Static: $STATIC_BUCKET_ADDRESS"
    upload_static
    upload_public
}

upload_static() {
    echo "Uploading static assets to $STATIC_BUCKET_ADDRESS"
    gsutil -m rsync -p "$PROJECT_ID" -u -r "$STATIC" "$STATIC_BUCKET_ADDRESS"
}

upload_public() {
    echo "Uploading public assets to $PUBLIC_BUCKET_ADDRESS"
    gsutil -m rsync -p "$PROJECT_ID" -u -r "$PUBLIC" "$PUBLIC_BUCKET_ADDRESS/"
}

case "$1" in
    development) upload_assets_to_cdn "$DEVELOPMENT_PROJECT" ;;
    production) upload_assets_to_cdn "$PRODUCTION_PROJECT" ;;
    *) echo "Invalid configuration: $1" && exit 1 ;;
esac
