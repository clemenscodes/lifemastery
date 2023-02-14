#!/bin/sh

set -e

export TF_IN_AUTOMATION=true

APP="landing"
APP_DIR="apps/clients/web/$APP"
PLAN="plan.tfplan"
PURPLE="\\033[0;35m"
SET="\\033[0m\\n"

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

deploy() {
    CONFIG="$1"
    TF_DIR="$APP_DIR/infra/$CONFIG"
    TF="terraform -chdir=$TF_DIR"
    BACKEND="$TF_DIR/backend.tf"
    BACKEND_ARG="-backend-config=bucket=$APP-$CONFIG-state"
    PLAN_ARG="-out=$PLAN"
    INPUT_ARG="-input=false"
    LOCK_ARG="-lock=false"
    LOCK_TIMEOUT_ARG="-lock-timeout=60s"
    APPROVE_ARG="-auto-approve"
    DEFAULT_PLAN="$PLAN_ARG $INPUT_ARG $LOCK_TIMEOUT_ARG $LOCK_ARG $VAR_ARG"
    APPLY_ARGS="$INPUT_ARG $APPROVE_ARG $LOCK_ARG $LOCK_TIMEOUT_ARG $PLAN"
    if grep -q "local" "$BACKEND"; then
        local_plan
    else
        remote_plan
    fi
    rm "$TF_DIR/$PLAN"
    cleanup
}

local_plan() {
    $TF init
    default_plan
    sed -i 's/local/gcs/g' "$BACKEND"
    echo "Migrating state"
    echo "yes" | $TF init "$BACKEND_ARG"
}

remote_plan() {
    $TF init "$BACKEND_ARG"
    default_plan
}

default_plan() {
    TF_COMMAND="$TF plan $DEFAULT_PLAN"
    run_tf_command
    TF_COMMAND="$TF apply $APPLY_ARGS"
    run_tf_command
}

run_tf_command() {
    echo
    purple "$TF_COMMAND"
    echo
    eval "$TF_COMMAND"
}

purple() {
    printf "$PURPLE%s$SET" "$1"
}

case "$1" in
development) deploy "$1" ;;
production) deploy "$1" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
