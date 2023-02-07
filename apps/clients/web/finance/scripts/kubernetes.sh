#!/bin/sh
set -e
APP="finance"
APP_DIR="apps/clients/web/$APP"

kubectl apply -f kubernetes/ -R
kubectl apply -f $APP_DIR/kubernetes/deployment.yml
kubectl apply -f $APP_DIR/kubernetes/service.yml
