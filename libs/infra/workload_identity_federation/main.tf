locals {
  wif_principal = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${data.github_repository.repo.full_name}"
}

data "google_organization" "org" {
  domain = var.domain
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

resource "google_service_account_iam_binding" "gh_actions_policy" {
  service_account_id = google_service_account.gh_actions.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    local.wif_principal
  ]
}

data "github_repository" "repo" {
  full_name = "${var.repo_owner}/${var.repo}"
}
