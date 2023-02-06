#!/bin/sh

create_classic_certificate() {
    DESCRIPTION=""
    DOMAIN_LIST="static.lifemastery.tech"
    CERTIFICATE_NAME="static"
    gcloud compute ssl-certificates create "$CERTIFICATE_NAME" \
        --description="$DESCRIPTION" \
        --domains="$DOMAIN_LIST" \
        --global
}

create_certificate() {
    CERTIFICATE_NAME="static"
    DOMAIN_LIST="static.lifemastery.tech"
    gcloud certificate-manager certificates create "$CERTIFICATE_NAME" \
        --domains="$DOMAIN_LIST"
}

list_certificates() {
    gcloud compute ssl-certificates list --global
}

describe_certificate() {
    CERTIFICATE_NAME="static"
    gcloud compute ssl-certificates describe "$CERTIFICATE_NAME" \
       --global \
       --format="get(name,managed.status, managed.domainStatus)"
}

add_certificate_to_load_balancer() {
    TARGET_PROXY_NAME=""
    SSL_CERTIFICATE_LIST=""
    gcloud compute target-https-proxies update "$TARGET_PROXY_NAME" \
        --ssl-certificates "$SSL_CERTIFICATE_LIST" \
        --global-ssl-certificates \
        --global
}

list_https_proxies() {
   gcloud compute target-https-proxies list
}

describe_https_proxy() {
    TARGET_HTTPS_PROXY_NAME="finance-development-https-target-proxy"
    gcloud compute target-https-proxies describe "$TARGET_HTTPS_PROXY_NAME" \
        --global \
        --format="get(sslCertificates)"
}

test_certificate() {
   DOMAIN="static.lifemastery.tech"
   IP_ADDRESS="35.186.244.89"
   echo | openssl s_client -showcerts -servername "$DOMAIN" -connect "$IP_ADDRESS":443 -verify 99 -verify_return_error
}
# create_classic_certificate
# create_certificate
# list_certificates
# describe_certificate
# add_certificate_to_load_balancer
# list_https_proxies
# describe_https_proxy
# test_certificate
