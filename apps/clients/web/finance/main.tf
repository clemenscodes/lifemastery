module "workload_identity_federation" {
  source = "../../../../libs/infra/workload_identity_federation"
}

module "finance-development" {
  source                = "./infra"
  project_id            = var.dev_project_id
  project_name          = var.dev_project_name
  git_commit_sha        = var.git_commit_sha
  org_name              = module.workload_identity_federation.org_name
  service_account_email = module.workload_identity_federation.service_account_email
}

module "finance-production" {
  source                = "./infra"
  project_id            = var.prod_project_id
  project_name          = var.prod_project_name
  git_commit_sha        = var.git_commit_sha
  org_name              = module.workload_identity_federation.org_name
  service_account_email = module.workload_identity_federation.service_account_email
}
