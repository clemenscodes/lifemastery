#!/bin/sh
set -e

GITHUB_USERNAME="clemenscodes"
GITHUB_REPO_NAME="lifemastery"
SERVICE_ACCOUNT_NAME="github-actions" # Must match [a-zA-Z][a-zA-Z\d\-]*[a-zA-Z\d]
POOL="lifemastery-identities"
POOL_DISPLAY_NAME="LifeMastery"

PROVIDER="github"
PROVIDER_DISPLAY_NAME="github"
PROJECT_ID=$(gcloud config get project)
SERVICE_ACCOUNT="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
REPO="$GITHUB_USERNAME/$GITHUB_REPO_NAME"
GITHUB_ACTIONS_IDENTITY_PROVIDER="https://token.actions.githubusercontent.com"
ATTRIBUTE_MAPPINGS="\
google.subject=assertion.sub,\
attribute.actor=assertion.actor,\
attribute.repository=assertion.repository,\
google.subject=assertion.sub,\
attribute.repository_owner=assertion.repository_owner,\
"

main() {
    echo "Setting up Workload Identity Federation"
    echo
    echo "GitHub User: $GITHUB_USERNAME"
    echo "GitHub Repository: $GITHUB_REPO_NAME"
    echo "Service Account Name: $SERVICE_ACCOUNT_NAME"
    echo "Pool: $POOL"
    echo "Pool Display Name: $POOL_DISPLAY_NAME"
    echo
    create_service_account
    echo
    enable_iam_api
    echo
    create_workload_identity_pool
    echo
    get_workload_identity_pool_id
    echo
    create_workload_identity_provider_in_pool
    echo
    allow_auth_from_provider
    echo
    extract_provider_resource_name
    echo
    echo "Set up Workload Identity Federation"
    echo
    echo "workload_identity_provider: $WORKLOAD_IDENTITY_POOL_ID"
    echo "service_account: $SERVICE_ACCOUNT"
}

create_service_account() {
    echo "Creating Service Account: $SERVICE_ACCOUNT_NAME"
    echo "gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --project $PROJECT_ID"
    echo
    gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" --project "$PROJECT_ID"
    echo "Created Service Account: $SERVICE_ACCOUNT_NAME"
}

enable_iam_api() {
    echo "Enabling IAM API in project: $PROJECT_ID"
    echo "gcloud services enable iamcredentials.googleapis.com --project $PROJECT_ID"
    echo
    gcloud services enable iamcredentials.googleapis.com --project "$PROJECT_ID"
    echo "Enabled IAM API"
}

create_workload_identity_pool() {
    echo "Creating Workload Identity Pool $POOL in project $PROJECT_ID"
    echo "gcloud iam workload-identity-pools create $POOL \\
    --project=$PROJECT_ID \\
    --location=\"global\" \\
    --display-name=$POOL_DISPLAY_NAME"
    echo
    gcloud iam workload-identity-pools create "$POOL" \
      --project="$PROJECT_ID" \
      --location="global" \
      --display-name="$POOL_DISPLAY_NAME"
    echo "Created Workload Identity Pool $POOL in project $PROJECT_ID"
}

get_workload_identity_pool_id() {
    echo "Getting Workload Identity Pool ID in project $PROJECT_ID"
    echo "gcloud iam workload-identity-pools describe $POOL \\
    --project=$PROJECT_ID \\
    --location=\"global\" \\
    --format='value(name)')"
    echo
    WORKLOAD_IDENTITY_POOL_ID="$(gcloud iam workload-identity-pools describe "$POOL" \
      --project="$PROJECT_ID" \
      --location="global" \
      --format="value(name)")"
    echo "Workload Identity Pool ID: $WORKLOAD_IDENTITY_POOL_ID"
}

create_workload_identity_provider_in_pool() {
    echo "Creating Workload Identity Provider $PROVIDER in pool $POOL"
    echo "gcloud iam workload-identity-pools providers create-oidc $PROVIDER \\
    --project=$PROJECT_ID \\
    --location=\"global\" \\
    --workload-identity-pool=$POOL \\
    --display-name=$PROVIDER_DISPLAY_NAME \\
    --attribute-mapping=\"$ATTRIBUTE_MAPPINGS\" \\
    --issuer-uri=$GITHUB_ACTIONS_IDENTITY_PROVIDER"
    echo
    gcloud iam workload-identity-pools providers create-oidc "$PROVIDER" \
      --project="$PROJECT_ID" \
      --location="global" \
      --workload-identity-pool="$POOL" \
      --display-name="$PROVIDER_DISPLAY_NAME" \
      --attribute-mapping="$ATTRIBUTE_MAPPINGS" \
      --issuer-uri="$GITHUB_ACTIONS_IDENTITY_PROVIDER"
    echo "Created Workload Identity Provider $PROVIDER in pool $POOL"
}

allow_auth_from_provider() {
    echo "Allowing Authentication for $SERVICE_ACCOUNT from Workload Identity Pool in repository $REPO"
    echo "gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT \\
    --project=$PROJECT_ID \\
    --role=\"roles/iam.workloadIdentityUser\" \\
    --member=\"principalSet://iam.googleapis.com/$WORKLOAD_IDENTITY_POOL_ID/attribute.repository/$REPO\""
    echo
    gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT" \
      --project="$PROJECT_ID" \
      --role="roles/iam.workloadIdentityUser" \
      --member="principalSet://iam.googleapis.com/$WORKLOAD_IDENTITY_POOL_ID/attribute.repository/$REPO"
    echo "Allowed Authentication for $SERVICE_ACCOUNT from Workload Identity Pool in repository $REPO"
}

extract_provider_resource_name() {
    echo "Extracting workload identity provider resource for provider $PROVIDER in pool $POOL"
    echo "gcloud iam workload-identity-pools providers describe $PROVIDER \\
    --project=$PROJECT_ID \\
    --location=\"global\" \\
    --workload-identity-pool=$POOL \\
    --format='value(name)'"
    echo
    gcloud iam workload-identity-pools providers describe "$PROVIDER" \
      --project="$PROJECT_ID" \
      --location="global" \
      --workload-identity-pool="$POOL" \
      --format="value(name)"
    echo "Extracted workload identity provider resource for provider $PROVIDER in pool $POOL"
}

main
