#!/bin/sh

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

image() {
    CONFIG="$1"
    if [ -z "$CI" ]; then
        INPUT_TAGS=$(git rev-parse --short HEAD) nx image web-finance --no-dte --configuration="$CONFIG"
    else
        if [ -z "$GH_TOKEN_FILE" ]; then
            echo "Missing GitHub token file"
            exit 1
        fi
        INPUT_GITHUB_TOKEN=$(cat "$GH_TOKEN_FILE") $(git rev-parse --short HEAD) nx image web-finance --configuration="$CONFIG"
    fi
}

case "$1" in
development) image "$1" ;;
production) image "$1" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
