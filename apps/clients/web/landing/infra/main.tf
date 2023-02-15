module "wif_data" {
  source = "../../../../../libs/infra/workload_identity_federation/data"
}

resource "google_folder" "default" {
  display_name = var.folder_name
  parent       = module.wif_data.org_name
}

resource "google_project_service" "iam_credentials" {
  project = var.project_id
  service = "iamcredentials.googleapis.com"
}

resource "google_project" "default" {
  name            = var.project_name
  project_id      = var.project_id
  billing_account = var.billing_account
  folder_id       = google_folder.default.folder_id
  labels = {
    "firebase" = "enabled"
  }
}

resource "google_project_iam_member" "wif" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = module.wif_data.wif_principal
}

resource "google_project_iam_member" "wif_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = module.wif_data.wif_principal
}

resource "google_project_iam_member" "wif_service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = module.wif_data.wif_principal
}

resource "google_project_iam_member" "iam_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${module.wif_data.service_account_email}"
}

resource "google_project_iam_member" "iam_service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${module.wif_data.service_account_email}"
}

resource "google_project_iam_member" "firebasehosting_admin" {
  project = var.project_id
  role    = "roles/firebasehosting.admin"
  member  = "serviceAccount:${module.wif_data.service_account_email}"
}

module "state_bucket" {
  source     = "../../../../../libs/infra/bucket/state"
  project_id = var.project_id
  bucket     = var.state_bucket
}
