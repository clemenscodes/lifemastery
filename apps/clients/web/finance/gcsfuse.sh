#!/usr/bin/env bash
set -eo pipefail

MNT_DIR="/app/sync/dist/$APP_DIR/.next/server/pages"
# Create mount directory for service
mkdir -p "$MNT_DIR"
chown nextjs:nodejs "$MNT_DIR" "$GOOGLE_APPLICATION_CREDENTIALS"

echo "Mounting GCS Fuse."
gcsfuse_command="gcsfuse -o nonempty --key-file=$GOOGLE_APPLICATION_CREDENTIALS --foreground --debug_gcs --implicit-dirs $BUCKET $MNT_DIR"
echo "$gcsfuse_command"
exec su - nextjs -c "$gcsfuse_command" &
echo "Mounting completed."

# mv "$APP_HOME"/static "$APP_HOME"/dist/"$APP_DIR"/.next/static

# Run the web app on container startup.
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
sleep 1
exec su - nextjs -c "node /app/$APP_DIR/server.js" &

# Exit immediately when one of the background processes terminate.
wait -n
