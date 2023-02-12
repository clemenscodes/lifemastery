terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.52.0"
    }
  }
}

module "finance" {
  source       = "../"
  project_name = var.project_name
  project_id   = var.project_id
  state_bucket = var.state_bucket
}

module "run" {
  source                 = "../../../../../../libs/infra/run"
  git_commit_sha         = var.git_commit_sha
  org_name               = module.finance.org_name
  project_id             = var.project_id
  project_name           = var.project_name
  folder_name            = "finance"
  repository_id          = "finance"
  cloud_run_service_name = "finance"
  cloud_run_region       = "europe-west1"
  artifact_region        = "europe-west3"
  registry_url           = "docker.pkg.dev"
  image_name             = "web"
}
