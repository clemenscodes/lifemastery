resource "google_folder" "default" {
  display_name = var.folder_name
  parent       = var.org_name
}

resource "google_project" "default" {
  name       = var.project_name
  project_id = var.project_id
  folder_id  = google_folder.default.folder_id
}

module "artifact-registry-repository" {
  source        = "../../../../infra/artifact"
  location      = var.artifact_region
  project       = var.project_id
  repository_id = var.repository_id
}

module "project_iam_bindings_workflow_federation_service_account" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  mode     = "authoritative"
  bindings = {
    "roles/storage.objectAdmin"            = ["serviceAccount:${var.workflow_service_account_email}"]
    "roles/storage.admin"                  = ["serviceAccount:${var.workflow_service_account_email}"]
    "roles/artifactregistry.admin"         = ["serviceAccount:${var.workflow_service_account_email}"]
    "roles/artifactregistry.serviceAgent"  = ["serviceAccount:${var.workflow_service_account_email}"]
    "roles/run.admin"                      = ["serviceAccount:${var.workflow_service_account_email}"]
    "roles/run.serviceAgent"               = ["serviceAccount:${var.workflow_service_account_email}"]
    "roles/iam.serviceAccountTokenCreator" = ["serviceAccount:${var.workflow_service_account_email}"]
    "roles/iam.serviceAccountUser"         = ["serviceAccount:${var.workflow_service_account_email}"]
  }
}

module "run" {
  source                 = "../../../../infra/run"
  project_id             = var.project_id
  project_name           = var.project_name
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
