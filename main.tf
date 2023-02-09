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

provider "google" {
  region  = var.region
  project = var.project
}

resource "google_service_account" "gh_actions" {
  account_id   = "gh-actions"
  display_name = "gh-actions"
}

resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "gh-workload-identity"
  display_name              = "Workload Identity Pool"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub Identity Provider"
  attribute_mapping = {
    "google.subject"             = "assertion.sub",
    "attribute.actor"            = "assertion.actor",
    "attribute.repository"       = "assertion.repository",
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_binding" "gh_actions_policy" {
  service_account_id = google_service_account.gh_actions.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.repository/${var.repo}"
  ]
}

provider "github" {
  owner = var.owner
}

data "github_repository" "repo" {
    full_name = "${var.owner}/${var.repo}"
}

resource "github_actions_secret" "workload_identity_provider" {
  repository = data.github_repository.repo.full_name
  secret_name       = "WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value = google_iam_workload_identity_pool_provider.github.name
}

resource "github_actions_secret" "service_account" {
  repository = data.github_repository.repo.full_name
  secret_name       = "SERVICE_ACCOUNT"
  plaintext_value = google_service_account.gh_actions.email
}

module "finance" {
  source         = "./apps/clients/web/finance"
  git_commit_sha = var.git_commit_sha
}

module "landing" {
  source = "./apps/clients/web/landing"
}
