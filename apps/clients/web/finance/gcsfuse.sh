#!/usr/bin/env bash
set -eo pipefail

SERVICE_ACCOUNT="lifemastery@landing-production-375914.iam.gserviceaccount.com"
BUCKET_ADDRESS="gs://$BUCKET"
CONTAINER_PAGES="$APP_HOME/dist/$APP_DIR/.next/server/pages"
MNT_DIR="/app/gcsfuse"

cmd() {
    su - nextjs -c "$1"
}

cmd "gcloud auth activate-service-account $SERVICE_ACCOUNT --key-file=$GOOGLE_APPLICATION_CREDENTIALS"

mkdir -p "$MNT_DIR"
chown -R nextjs:nodejs "$APP_HOME"

echo "Mounting GCS Fuse."
gcsfuse_command="gcsfuse -o nonempty --key-file=$GOOGLE_APPLICATION_CREDENTIALS --foreground --debug_gcs --implicit-dirs $BUCKET $MNT_DIR"
echo "$gcsfuse_command"
exec su - nextjs -c "$gcsfuse_command" &
echo "Mounting completed."

echo "Syncing newer files from bucket to app..."
cmd "gsutil -m rsync -u -r $BUCKET_ADDRESS $CONTAINER_PAGES"
echo "Done syncing newer files from bucket to app"

echo "Starting Next.js app..."
exec su - nextjs -c "node $APP_HOME/$APP_DIR/server.js" &
echo "Next.js app started"

# Exit immediately when one of the background processes terminate.
wait -n

cmd "gsutil -m rsync -r $CONTAINER_PAGES $BUCKET_ADDRESS"
