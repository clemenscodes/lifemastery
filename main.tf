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

resource "google_project" "default" {
  name       = var.default_project_name
  project_id = var.default_project_id
  org_id     = data.google_organization.org.org_id
}

resource "google_folder" "landing" {
  display_name = var.default_folder_name
  parent       = data.google_organization.org.name
}

resource "google_service_account" "gh_actions" {
  account_id = var.workload_identity_service_account_id
  project    = google_project.default.project_id
}

resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = var.workload_identity_pool_id
  project                   = google_project.default.project_id
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
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.repository/${var.repo}"
  ]
}

data "github_repository" "repo" {
  full_name = "${var.repo_owner}/${var.repo}"
}

resource "github_actions_secret" "workload_identity_provider" {
  repository      = data.github_repository.repo.full_name
  secret_name     = "WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value = google_iam_workload_identity_pool_provider.github.name
}

resource "github_actions_secret" "service_account" {
  repository      = data.github_repository.repo.full_name
  secret_name     = "SERVICE_ACCOUNT"
  plaintext_value = google_service_account.gh_actions.email
}

module "finance-development" {
  source                         = "./apps/clients/web/finance"
  git_commit_sha                 = var.git_commit_sha
  org_name                       = data.google_organization.org.name
  workflow_service_account_email = google_service_account.gh_actions.email
  project_name                   = "finance-development"
  project_id                     = "finance-development-375914"
}

module "finance-production" {
  source                         = "./apps/clients/web/finance"
  git_commit_sha                 = var.git_commit_sha
  org_name                       = data.google_organization.org.name
  workflow_service_account_email = google_service_account.gh_actions.email
  project_name                   = "finance-production"
  project_id                     = "finance-production-375914"
}

module "landing" {
  source = "./apps/clients/web/landing"
}
