terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.52.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 5.17.0"
    }
  }
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
  project                   = google_project.default.project_id
  display_name              = "Workload Identity Pool"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_pool_id
  attribute_mapping = {
    "google.subject"             = "assertion.sub",
    "attribute.actor"            = "assertion.actor",
    "attribute.repository"       = "assertion.repository",
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  project = google_project.default.project_id
}

resource "google_service_account_iam_binding" "gh_actions_policy" {
  service_account_id = google_service_account.gh_actions.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${data.github_repository.repo.full_name}"
  ]
}

data "github_repository" "repo" {
  full_name = "${var.repo_owner}/${var.repo}"
}

# resource "github_actions_secret" "workload_identity_provider" {
#   repository      = data.github_repository.repo.full_name
#   secret_name     = "WORKLOAD_IDENTITY_PROVIDER"
#   plaintext_value = google_iam_workload_identity_pool_provider.github.name
# }

# resource "github_actions_secret" "service_account" {
#   repository      = data.github_repository.repo.full_name
#   secret_name     = "SERVICE_ACCOUNT"
#   plaintext_value = google_service_account.gh_actions.email
# }
