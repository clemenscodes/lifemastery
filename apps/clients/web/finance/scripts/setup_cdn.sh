#!/bin/sh
set -e
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

create_cdn() {
    PROJECT_ID="$1"
    DOMAIN="$2"
    CONFIG="$3"
    SUBDOMAIN="$4"
    CERTIFICATE_NAME="$APP-$CONFIG-certificate"
    echo "Creating cloud delivery network in project $PROJECT_ID for domain $DOMAIN"
    set_project "$PROJECT_ID"
    create_storage_bucket "$PROJECT_ID"
    make_bucket_readable
    create_external_static_ipv4
    get_ip
    create_global_backend_bucket
    add_url_map_to_backend_bucket
    create_certificate "$DOMAIN" "$CERTIFICATE_NAME"
    list_certificates
    describe_certificate
    add_target_proxy
    add_traffic_redirect_rule
    list_https_proxies
    describe_https_proxy
    generate_dns_entry "$SUBDOMAIN"
}

set_project() {
    gcloud config set project "$1"
}

create_storage_bucket() {
    echo "Creating storage bucket in project $1 and region $REGION with name $BUCKET_NAME"
    gsutil mb -p "$1" -c standard -l "$REGION" -b on gs://"$BUCKET_NAME"
}

make_bucket_readable() {
    echo "Making bucket $BUCKET_NAME publicly readable"
    gsutil iam ch allUsers:objectViewer gs://"$BUCKET_NAME"
}

create_external_static_ipv4() {
    echo "Creating external static IP address with name $IP_NAME"
    gcloud compute addresses create "$IP_NAME" \
        --network-tier=PREMIUM \
        --ip-version=IPV4 \
        --global
}

get_ip() {
    echo "Getting IP of $IP_NAME IP"
    IP=$(gcloud compute addresses describe "$IP_NAME" \
    --format="get(address)" \
    --global)
    echo "$IP_NAME IP: $IP"
}

create_global_backend_bucket() {
    echo "Creating backend bucket for bucket $BUCKET_NAME"
    gcloud compute backend-buckets create "$BUCKET_NAME" \
        --gcs-bucket-name="$BUCKET_NAME" \
        --cache-mode="CACHE_ALL_STATIC" \
        --enable-cdn
}

add_url_map_to_backend_bucket() {
    echo "Adding url map $URL_MAP to backend bucket $BUCKET_NAME"
    gcloud compute url-maps create "$URL_MAP" \
        --default-backend-bucket="$BUCKET_NAME" \
        --global
}

create_certificate() {
    echo "Creating SSL certificate $CERTIFICATE_NAME for domain $DOMAIN"
    gcloud compute ssl-certificates create "$CERTIFICATE_NAME" \
        --domains="$DOMAIN" \
        --global
}

list_certificates() {
    echo "Listing certificates"
    gcloud compute ssl-certificates list --global
}

describe_certificate() {
    echo "Describing $CERTIFICATE_NAME certificate"
    gcloud compute ssl-certificates describe "$CERTIFICATE_NAME" \
       --global \
       --format="get(name,managed.status, managed.domainStatus)"
}

add_target_proxy() {
    echo "Creating target https proxy $PROXY_NAME with url map $URL_MAP"
    gcloud compute target-https-proxies create "$PROXY_NAME" \
        --url-map="$URL_MAP" \
        --ssl-certificates="$CERTIFICATE_NAME" \
        --global \
        --global-ssl-certificates
}

add_traffic_redirect_rule() {
    echo "Adding traffic redirect rule $FORWARDING_RULE"
    gcloud compute forwarding-rules create "$FORWARDING_RULE" \
        --load-balancing-scheme="EXTERNAL_MANAGED" \
        --network-tier=PREMIUM \
        --address="$IP_NAME" \
        --global \
        --target-https-proxy="$PROXY_NAME" \
        --ports=443
}

list_https_proxies() {
    echo "Listing target https proxies"
    gcloud compute target-https-proxies list
}

describe_https_proxy() {
    echo "Describing target https proxy $PROXY_NAME"
    gcloud compute target-https-proxies describe "$PROXY_NAME" \
        --global \
        --format="get(sslCertificates)"
}

generate_dns_entry() {
    echo "Add this DNS entry to the domain $APEX"
    echo "Type:  A"
    echo "Host:  $1"
    echo "Value: $IP"
}

test_certificate() {
    echo "Testing SSL certificate for domain $DOMAIN on IP $IP"
    echo | openssl s_client -showcerts -servername "$DOMAIN" -connect "$IP":443 -verify 99 -verify_return_error
}

test_cdn() {
    echo "Testing CDN on URL $URL"
    URL="https://$IP"
    curl "$URL"
}

case "$1" in
    development) create_cdn "$DEVELOPMENT_PROJECT" "$DEV.$APEX" "$1" $DEV ;;
    production) create_cdn "$PRODUCTION_PROJECT" "$PROD.$APEX" "$1" $PROD ;;
    *) echo "Invalid configuration: $1" && exit 1 ;;
esac
