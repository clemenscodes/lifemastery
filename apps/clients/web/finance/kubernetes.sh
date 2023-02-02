#!/bin/sh

APP="finance"
APP_DIR="apps/clients/web/$APP"

kubectl apply -f kubernetes/ -R
kubectl apply -f $APP_DIR/deployment.yml
kubectl apply -f $APP_DIR/service.yml
