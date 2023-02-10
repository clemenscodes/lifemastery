module "workload_identity_federation" {
  source = "../../../../libs/infra/workload_identity_federation"
}

resource "google_folder" "default" {
  display_name = var.folder_name
  parent       = module.workload_identity_federation.org_name
}

resource "google_project" "default" {
  name            = var.project_name
  project_id      = var.project_id
  billing_account = var.billing_account
  folder_id       = google_folder.default.folder_id
}

# module "project_iam_bindings" {
#   source   = "terraform-google-modules/iam/google//modules/projects_iam"
#   projects = [var.project_id]
#   mode     = "authoritative"
#   bindings = {
#     "roles/storage.objectAdmin"            = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
#     "roles/storage.admin"                  = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
#     "roles/artifactregistry.admin"         = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
#     "roles/artifactregistry.serviceAgent"  = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
#     "roles/run.admin"                      = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
#     "roles/run.serviceAgent"               = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
#     "roles/iam.serviceAccountTokenCreator" = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
#     "roles/iam.serviceAccountUser"         = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
#   }
# }

# module "artifact-registry-repository" {
#   source        = "../../../../libs/infra/artifact"
#   location      = var.artifact_region
#   project       = var.project_id
#   repository_id = var.repository_id
# }

# module "run" {
#   source                 = "../../../../libs/infra/run"
#   project_id             = var.project_id
#   project_name           = var.project_name
#   folder_name            = var.folder_name
#   cloud_run_region       = var.cloud_run_region
#   cloud_run_service_name = var.cloud_run_service_name
#   repository_id          = var.repository_id
#   artifact_region        = var.artifact_region
#   registry_url           = var.registry_url
#   image_name             = var.image_name
#   git_commit_sha         = var.git_commit_sha
#   org_name               = module.workload_identity_federation.org_name
# }
