#!/usr/bin/env bash
set -eo pipefail

# Create mount directory for service
echo "mnt: $MNT_DIR"
mkdir -p "$MNT_DIR"
ls "$MNT_DIR"
chown nextjs:nodejs "$MNT_DIR" "$GOOGLE_APPLICATION_CREDENTIALS"
ls "$MNT_DIR"

echo "Mounting GCS Fuse."
gcsfuse_command="gcsfuse -o nonempty --key-file=$GOOGLE_APPLICATION_CREDENTIALS --foreground --debug_http --debug_gcs --debug_fuse --implicit-dirs $BUCKET $MNT_DIR"
echo "$gcsfuse_command"
exec su - nextjs -c "$gcsfuse_command" &
echo "Mounting completed."

# mv "$APP_HOME"/static "$APP_HOME"/dist/"$APP_DIR"/.next/static

# Run the web app on container startup.
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
sleep 2
exec su - nextjs -c "cp -r /app/dist/$APP_DIR/.next/static /app/buckets/static && node /app/$APP_DIR/server.js" &

# Exit immediately when one of the background processes terminate.
wait -n
