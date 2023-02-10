#!/bin/sh

APP="finance"
APP_DIR="apps/clients/web/$APP"
TF="terraform -chdir=$APP_DIR"
SHA="$(git rev-parse --short HEAD)"

$TF init
$TF plan -var git_commit_sha="$SHA"
