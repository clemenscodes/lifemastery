module "workload_identity_federation" {
  source = "../../../../../libs/infra/workload_identity_federation"
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

module "state_bucket" {
  source       = "../../../../../libs/infra/bucket/state_bucket"
  project_id   = var.project_id
  state_bucket = var.state_bucket
}

module "project_iam_bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  bindings = {
    "roles/storage.objectAdmin"            = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
    "roles/storage.admin"                  = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
    "roles/artifactregistry.admin"         = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
    "roles/artifactregistry.serviceAgent"  = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
    "roles/run.admin"                      = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
    "roles/run.serviceAgent"               = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
    "roles/iam.serviceAccountTokenCreator" = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
    "roles/iam.serviceAccountUser"         = ["serviceAccount:${module.workload_identity_federation.service_account_email}"]
  }
}

module "artifact-registry-repository" {
  source        = "../../../../../libs/infra/artifact"
  location      = var.artifact_region
  project       = var.project_id
  repository_id = var.repository_id
}
