locals {
  wif_principal = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.repo_owner}/${var.repo}"
}

data "google_organization" "org" {
  domain = var.domain
}

resource "google_organization_iam_member" "organization_admin" {
  org_id = data.google_organization.org.org_id
  role   = "roles/resourcemanager.organizationAdmin"
  member = "serviceAccount:${google_service_account.gh_actions.email}"
}

resource "google_organization_iam_member" "workload_identity_pool_admin" {
  org_id = data.google_organization.org.org_id
  role   = "roles/iam.workloadIdentityPoolAdmin"
  member = "serviceAccount:${google_service_account.gh_actions.email}"
}

resource "google_folder" "default" {
  display_name = var.default_folder_name
  parent       = data.google_organization.org.name
}

resource "google_project" "default" {
  billing_account = var.billing_account
  name            = var.default_project_name
  project_id      = var.default_project_id
  folder_id       = google_folder.default.name
  labels = {
    "firebase" = "enabled"
  }
}

resource "google_service_account" "gh_actions" {
  account_id = var.workload_identity_service_account_id
  project    = google_project.default.project_id
}

resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = var.workload_identity_pool_id
  disabled                  = false
  project                   = google_project.default.number
  display_name              = "Workload Identity Pool"
  timeouts {}
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  disabled                           = false
  project                            = google_project.default.number
  workload_identity_pool_provider_id = var.workload_identity_provider_pool_id
  attribute_mapping = {
    "google.subject"             = "assertion.sub",
    "attribute.actor"            = "assertion.actor",
    "attribute.repository"       = "assertion.repository",
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    allowed_audiences = []
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
  timeouts {}
}

resource "google_project_iam_member" "wif" {
  project = var.default_project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = local.wif_principal
}

resource "google_project_iam_member" "wif_service_account_token_creator" {
  project = var.default_project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = local.wif_principal
}

resource "google_project_iam_member" "wif_service_account_user" {
  project = var.default_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = local.wif_principal
}

resource "google_project_iam_member" "iam_service_account_user" {
  project = var.default_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.gh_actions.email}"
}

resource "google_project_iam_member" "iam_service_account_token_creator" {
  project = var.default_project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.gh_actions.email}"
}
