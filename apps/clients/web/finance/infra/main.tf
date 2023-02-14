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

resource "google_project_iam_member" "run_service_agent" {
  project = var.project_id
  role    = "roles/run.serviceAgent"
  member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
}

resource "google_project_iam_member" "storage_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
}

resource "google_project_iam_member" "run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
}

resource "google_project_iam_member" "artifact_registry_service_agent" {
  project = var.project_id
  role    = "roles/artifactregistry.serviceAgent"
  member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
}

resource "google_project_iam_member" "artifact_registry_admin" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
}

# resource "google_project_iam_member" "ssl_certificate_get" {
#   project = var.project_id
#   role    = "roles/compute.sslCertificates.get"
#   member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
# }

# resource "google_project_iam_member" "ssl_certificate_create" {
#   project = var.project_id
#   role    = "roles/compute.sslCertificates.create"
#   member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
# }

# resource "google_project_iam_member" "ssl_certificate_update" {
#   project = var.project_id
#   role    = "roles/compute.sslCertificates.update"
#   member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
# }

# resource "google_project_iam_member" "ip_get" {
#   project = var.project_id
#   role    = "roles/compute.globalAddresses.get"
#   member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
# }

# resource "google_project_iam_member" "ip_create" {
#   project = var.project_id
#   role    = "roles/compute.globalAddresses.create"
#   member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
# }

# resource "google_project_iam_member" "ip_update" {
#   project = var.project_id
#   role    = "roles/compute.globalAddresses.update"
#   member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
# }

# resource "google_project_iam_member" "backend_buckets_update" {
#   project = var.project_id
#   role    = "roles/compute.backendBuckets.update"
#   member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
# }

# resource "google_project_iam_member" "backend_buckets_create" {
#   project = var.project_id
#   role    = "roles/compute.backendBuckets.create"
#   member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
# }

# resource "google_project_iam_member" "backend_buckets_get" {
#   project = var.project_id
#   role    = "roles/compute.backendBuckets.get"
#   member  = "serviceAccount:${module.workload_identity_federation.service_account_email}"
# }

module "state_bucket" {
  source     = "../../../../../libs/infra/bucket/state"
  project_id = var.project_id
  bucket     = var.state_bucket
}

module "artifact-registry-repository" {
  source        = "../../../../../libs/infra/artifact"
  location      = var.artifact_region
  project       = var.project_id
  repository_id = var.repository_id
}

module "isr_bucket" {
  source     = "../../../../../libs/infra/bucket/isr"
  project_id = var.project_id
  bucket     = var.isr_bucket
}

module "cdn" {
  source           = "../../../../../libs/infra/cdn"
  domain           = module.workload_identity_federation.domain
  project_id       = var.project_id
  bucket           = var.cdn_bucket
  region           = var.cdn_region
  subdomain        = var.subdomain
  certificate_name = "${var.project_name}-certificate"
}
