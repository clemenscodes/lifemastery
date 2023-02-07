#!/bin/sh
set -e
DEVELOPMENT_PROJECT="finance-development-375914"
PRODUCTION_PROJECT="finance-production-375914"
FULL_BUCKET_ADDRESS="$(gsutil ls | grep cdn)"
BUCKET="$(echo "$FULL_BUCKET_ADDRESS" | awk -F '/' '{print $3}')"
BUCKET_ADDRESS="gs://$BUCKET"
PUBLIC="dist/apps/clients/web/finance/public"
STATIC="dist/apps/clients/web/finance/.next/static"

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
    gcloud config set project "$PROJECT_ID"
}

upload_static() {
    gsutil -m rsync -u -r "$STATIC" "$BUCKET_ADDRESS/_next/static/"
}

upload_public() {
    gsutil -m rsync -u -r "$PUBLIC" "$BUCKET_ADDRESS/public/"
}

case "$1" in
    development) upload_assets_to_cdn "$DEVELOPMENT_PROJECT" ;;
    production) upload_assets_to_cdn "$PRODUCTION_PROJECT" ;;
    *) echo "Invalid configuration: $1" && exit 1 ;;
esac
