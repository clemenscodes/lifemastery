#!/bin/sh

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

image() {
    CONFIG="$1"
    if [ -z "$CI" ]; then
        INPUT_TAGS=$(git rev-parse --short HEAD) nx image web-finance --no-dte --configuration="$CONFIG"
    else
        if [ -z "$INPUT_GITHUB_TOKEN" ]; then
            echo "Missing GitHub token"
            exit 1
        fi
        NEXT_PUBLIC_PROJECT_TYPE=$CONFIG nx build web-finance --skip-nx-cache
        INPUT_GITHUB_TOKEN=$INPUT_GITHUB_TOKEN INPUT_TAGS=$(git rev-parse --short HEAD) nx image web-finance --skip-nx-cache --configuration="$CONFIG"
    fi
}

case "$1" in
development) image "$1" ;;
production) image "$1" ;;
*) echo "Invalid configuration: $1" && exit 1 ;;
esac
