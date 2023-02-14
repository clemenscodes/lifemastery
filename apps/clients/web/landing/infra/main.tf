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

resource "google_project_iam_member" "wif" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = module.workload_identity_federation.wif_principal
}

resource "google_project_iam_member" "wif_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = module.workload_identity_federation.wif_principal
}

resource "google_project_iam_member" "wif_service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = module.workload_identity_federation.wif_principal
}

resource "google_project_iam_member" "iam_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
}

resource "google_project_iam_member" "iam_service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
}

module "state_bucket" {
  source     = "../../../../../libs/infra/bucket/state"
  project_id = var.project_id
  bucket     = var.state_bucket
}
