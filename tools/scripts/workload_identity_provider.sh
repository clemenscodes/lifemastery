#!/bin/sh
set -e

SERVICE_ACCOUNT_NAME="gh-actions" # Must match [a-zA-Z][a-zA-Z\d\-]*[a-zA-Z\d]
POOL="gh-workload-identity" # Must be between 4 and 32 characters
POOL_DISPLAY_NAME="Workload Identity Pool"
PROVIDER="github"
PROVIDER_DISPLAY_NAME="GitHub Identity Provider"
PROJECT_ID=$(gcloud config get project)
SERVICE_ACCOUNT="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
REPO="$(gh repo view --json nameWithOwner -q ".nameWithOwner")"
GITHUB_ACTIONS_IDENTITY_PROVIDER="https://token.actions.githubusercontent.com"
ATTRIBUTE_MAPPINGS="\
google.subject=assertion.sub,\
attribute.actor=assertion.actor,\
attribute.repository=assertion.repository,\
attribute.repository_owner=assertion.repository_owner\
"
create_service_account() {
    gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" --project "$PROJECT_ID"
}

enable_iam_api() {
    gcloud services enable iamcredentials.googleapis.com --project "$PROJECT_ID"
}

create_workload_identity_pool() {
    gcloud iam workload-identity-pools create "$POOL" \
      --project="$PROJECT_ID" \
      --location="global" \
      --display-name="$POOL_DISPLAY_NAME"
}

get_workload_identity_pool_id() {
    WORKLOAD_IDENTITY_POOL_ID="$(gcloud iam workload-identity-pools describe "$POOL" \
      --project="$PROJECT_ID" \
      --location="global" \
      --format="value(name)")"
}

create_workload_identity_provider_in_pool() {
    gcloud iam workload-identity-pools providers create-oidc "$PROVIDER" \
      --project="$PROJECT_ID" \
      --location="global" \
      --workload-identity-pool="$POOL" \
      --display-name="$PROVIDER_DISPLAY_NAME" \
      --attribute-mapping="$ATTRIBUTE_MAPPINGS" \
      --issuer-uri="$GITHUB_ACTIONS_IDENTITY_PROVIDER"
}

allow_auth_from_provider() {
    gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT" \
      --project="$PROJECT_ID" \
      --role="roles/iam.workloadIdentityUser" \
      --member="principalSet://iam.googleapis.com/$WORKLOAD_IDENTITY_POOL_ID/attribute.repository/$REPO"
}

extract_provider_resource_name() {
    WORKLOAD_IDENTITY_PROVIDER_ID=$(gcloud iam workload-identity-pools providers describe "$PROVIDER" \
      --project="$PROJECT_ID" \
      --location="global" \
      --workload-identity-pool="$POOL" \
      --format="value(name)")
}

set_secrets() {
    gh secret set WORKLOAD_IDENTITY_PROVIDER --body "$WORKLOAD_IDENTITY_PROVIDER_ID"
    gh secret set SERVICE_ACCOUNT --body "$SERVICE_ACCOUNT"
}

echo "Setting up Workload Identity Federation"
echo
echo "Repository:           $REPO"
echo "Service Account Name: $SERVICE_ACCOUNT_NAME"
echo "Pool:                 $POOL"
echo "Pool Display Name:    $POOL_DISPLAY_NAME"
echo
echo "Creating Service Account: $SERVICE_ACCOUNT_NAME"
echo "gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --project $PROJECT_ID"
echo
create_service_account
sleep 0.5
echo
echo "Enabling IAM API in project: $PROJECT_ID"
echo "gcloud services enable iamcredentials.googleapis.com --project $PROJECT_ID"
enable_iam_api
sleep 0.5
echo
echo "Creating Workload Identity Pool $POOL in project $PROJECT_ID"
echo "gcloud iam workload-identity-pools create $POOL \\
--project=$PROJECT_ID \\
--location=\"global\" \\
--display-name=\"$POOL_DISPLAY_NAME\""
echo
create_workload_identity_pool
sleep 0.5
echo
echo "Getting Workload Identity Pool ID in project $PROJECT_ID"
echo "gcloud iam workload-identity-pools describe $POOL \\
--project=$PROJECT_ID \\
--location=\"global\" \\
--format=\"value(name)\""
echo
get_workload_identity_pool_id
sleep 0.5
echo "Workload Identity Pool ID: $WORKLOAD_IDENTITY_POOL_ID"
echo
echo "Creating Workload Identity Provider $PROVIDER in pool $POOL"
echo "gcloud iam workload-identity-pools providers create-oidc $PROVIDER \\
--project=$PROJECT_ID \\
--location=\"global\" \\
--workload-identity-pool=$POOL \\
--display-name=$PROVIDER_DISPLAY_NAME \\
--attribute-mapping=\"$ATTRIBUTE_MAPPINGS\" \\
--issuer-uri=\"$GITHUB_ACTIONS_IDENTITY_PROVIDER\""
echo
create_workload_identity_provider_in_pool
sleep 0.5
echo
echo "Allowing Authentication for $SERVICE_ACCOUNT"
echo "gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT \\
--project=$PROJECT_ID \\
--role=\"roles/iam.workloadIdentityUser\" \\
--member=\"principalSet://iam.googleapis.com/$WORKLOAD_IDENTITY_POOL_ID/attribute.repository/$REPO\""
echo
allow_auth_from_provider
sleep 0.5
echo
echo "Extracting workload identity provider"
echo "gcloud iam workload-identity-pools providers describe $PROVIDER \\
--project=$PROJECT_ID \\
--location=\"global\" \\
--workload-identity-pool=$POOL \\
--format=\"value(name)\""
echo
extract_provider_resource_name
sleep 0.5
echo
echo "Setting repository secrets for GitHub Actions"
set_secrets
echo "Done"
