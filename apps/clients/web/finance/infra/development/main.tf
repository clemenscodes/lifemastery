terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.53.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.17.0"
    }
  }
}
provider "google" {
  access_token = var.access_token
}

module "finance" {
  source       = "../"
  project_name = var.project_name
  project_id   = var.project_id
  state_bucket = var.state_bucket
  isr_bucket   = var.isr_bucket
  cdn_bucket   = var.cdn_bucket
  cdn_region   = var.cdn_region
  subdomain    = var.cdn_subdomain
}

module "run" {
  source                 = "../../../../../../libs/infra/run"
  git_commit_sha         = var.git_commit_sha
  org_name               = module.finance.org_name
  domain                 = module.finance.domain
  cloud_run_subdomain    = var.cloud_run_subdomain
  project_id             = var.project_id
  project_name           = var.project_name
  folder_name            = "finance"
  repository_id          = "docker"
  cloud_run_service_name = "finance"
  cloud_run_region       = "europe-west1"
  artifact_region        = "europe-west1"
  registry_url           = "docker.pkg.dev"
  image_name             = "web"
}
