module "finance-development" {
  source                 = "../../../../infra/run"
  project_id             = var.dev_project_id
  project_name           = var.dev_project_name
  folder_name            = var.folder_name
  cloud_run_region       = var.cloud_run_region
  cloud_run_service_name = var.cloud_run_service_name
  repository_id          = var.repository_id
  artifact_region        = var.artifact_region
  registry_url           = var.registry_url
  image_name             = var.image_name
  org_name               = var.org_name
  git_commit_sha         = var.git_commit_sha
}

module "finance-production" {
  source                 = "../../../../infra/run"
  project_id             = var.prod_project_id
  project_name           = var.prod_project_name
  folder_name            = var.folder_name
  cloud_run_region       = var.cloud_run_region
  cloud_run_service_name = var.cloud_run_service_name
  repository_id          = var.repository_id
  artifact_region        = var.artifact_region
  registry_url           = var.registry_url
  image_name             = var.image_name
  org_name               = var.org_name
  git_commit_sha         = var.git_commit_sha
}
