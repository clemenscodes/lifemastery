module "finance-development" {
  source                 = "../../../../infra/run"
  git_commit_sha         = var.git_commit_sha
  org_name               = var.org_name
  folder_name            = var.folder_name
  cloud_run_region       = var.cloud_run_region
  cloud_run_service_name = var.cloud_run_service_name
  repository_id          = var.repository_id
  project_id             = var.project_id
  project_name           = var.project_name
}

module "finance-production" {
  source                 = "../../../../infra/run"
  git_commit_sha         = var.git_commit_sha
  org_name               = var.org_name
  folder_name            = var.folder_name
  cloud_run_region       = var.cloud_run_region
  cloud_run_service_name = var.cloud_run_service_name
  repository_id          = var.repository_id
  project_name           = "finance-production"
  project_id             = "finance-production-375914"
}
