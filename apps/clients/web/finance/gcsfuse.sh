#!/usr/bin/env bash
set -eo pipefail

SERVICE_ACCOUNT="lifemastery@landing-production-375914.iam.gserviceaccount.com"
BUCKET_ADDRESS="gs://$BUCKET"
CONTAINER_PAGES="$APP_HOME/dist/$APP_DIR/.next/server/pages"
SERVER="$APP_HOME/$APP_DIR/server.js"
MNT_DIR="$APP_HOME/$BUCKET"

sync() {
    echo "Syncing newer files from $1 to $2..."
    gsutil -m rsync -u -r "$1" "$2"
    echo "Done syncing files from $1 to $2..."
}

authorize_gcloud() {
    gcloud auth activate-service-account $SERVICE_ACCOUNT --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
}

mount_google_cloud_storage() {
    echo "Mounting GCS Fuse."
    exec gcsfuse --key-file="$GOOGLE_APPLICATION_CREDENTIALS" --foreground --debug_gcs "$BUCKET" "$MNT_DIR" &
    echo "Mounting completed."
    sync "$BUCKET_ADDRESS" "$CONTAINER_PAGES"
}

start_nextjs_app() {
    echo "Starting Next.js app..."
    exec node "$SERVER" &
    echo "Next.js app started"
}

cleanup() {
    echo "Cleaning up..."
    sync "$CONTAINER_PAGES" "$BUCKET_ADDRESS"
    echo "Adios."
}

authorize_gcloud
mount_google_cloud_storage
start_nextjs_app

# Exit immediately when one of the background processes terminate.
wait -n

cleanup
