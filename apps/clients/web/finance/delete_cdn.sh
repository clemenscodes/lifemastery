#!/bin/sh

APP="finance"
DEVELOPMENT_PROJECT="finance-development-375914"
PRODUCTION_PROJECT="finance-production-375914"
BUCKET_NAME="$APP-$1-cdn"
IP_NAME="$BUCKET_NAME-ip"
URL_MAP="$BUCKET_NAME-https-lb"
PROXY_NAME="$URL_MAP-proxy"
FORWARDING_RULE="$URL_MAP-forwarding-rule"
REGION="europe-west3"
APEX="lifemastery.tech"
DEV="dev.static.$APP"
PROD="static.$APP"

if [ -z "$1" ]; then
    echo "No configuration (development or production) was given" && exit 1
fi

delete_cdn() {
    PROJECT_ID="$1"
    DOMAIN="$2"
    CERTIFICATE_NAME="$APP-$3-certificate"
    echo "Deleting cloud delivery network in project $PROJECT_ID for domain $DOMAIN"
    set_project "$PROJECT_ID"
    delete_storage_bucket "$PROJECT_ID"
    delete_external_static_ipv4
    delete_traffic_redirect_rule
    delete_target_proxy
    delete_url_map
    delete_certificate
    delete_global_backend_bucket
}

set_project() {
    gcloud config set project "$1"
}

delete_storage_bucket() {
    echo "Deleting storage bucket in project $1 and region $REGION with name $BUCKET_NAME"
    gsutil rb gs://"$BUCKET_NAME"
}

delete_external_static_ipv4() {
    echo "Creating external static IP address with name $IP_NAME"
    echo "" | gcloud compute addresses delete "$IP_NAME" \
        --global
}

delete_traffic_redirect_rule() {
    echo "Deleting traffic redirect rule $FORWARDING_RULE"
    echo "" | gcloud compute forwarding-rules delete "$FORWARDING_RULE" \
        --global
}

delete_url_map() {
    echo "Deleting url map $URL_MAP"
    echo "" | gcloud compute url-maps delete "$URL_MAP" \
        --global
}

delete_certificate() {
    echo "Deleting SSL certificate $CERTIFICATE_NAME"
    echo "" | gcloud compute ssl-certificates delete "$CERTIFICATE_NAME" \
        --global
}

delete_target_proxy() {
    echo "Delete target https proxy $PROXY_NAME"
    echo "" | gcloud compute target-https-proxies delete "$PROXY_NAME" \
        --global
}

delete_global_backend_bucket() {
    echo "Deleting backend bucket for bucket $BUCKET_NAME"
    echo "" | gcloud compute backend-buckets delete "$BUCKET_NAME"
}

case "$1" in
    development) delete_cdn "$DEVELOPMENT_PROJECT" "$DEV.$APEX" "$1" ;;
    production) delete_cdn "$PRODUCTION_PROJECT" "$PROD.$APEX" "$1" ;;
    *) echo "Invalid configuration: $1" && exit 1 ;;
esac
