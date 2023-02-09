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
  source        = "../artifact"
  location      = var.artifact_region
  project       = var.project_id
  repository_id = var.repository_id
}

resource "google_service_account" "cloud_run_service_account" {
  account_id  = var.project_name
  description = "The service account that will be used by the Cloud Run instance. Needs access to Cloud Storage"
}

resource "google_project_iam_binding" "run-admin-binding" {
  project = var.project_id
  role    = "roles/run.admin"
  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]
}

resource "google_project_iam_binding" "run-service-agent-binding" {
  project = var.project_id
  role    = "roles/run.serviceAgent"
  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]
}

resource "google_project_iam_binding" "service-account-user-binding" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]
}

resource "google_project_iam_binding" "storage-admin-binding" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]
}

resource "google_project_iam_binding" "storage-object-admin-binding" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]
}

resource "google_cloud_run_v2_service" "default" {
  name     = var.cloud_run_service_name
  location = var.cloud_run_region
  project  = var.project_id
  template {
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"
    max_instance_request_concurrency = 80
    timeout                          = 300
    service_account                  = google_service_account.cloud_run_service_account.email
    annotations = {
      "run.googleapis.com/ingress" = "all"
    }
    scaling {
      min_instance_count = 0
      max_instance_count = 1000
    }
    containers {
      image = "${var.artifact_region}-${var.registry_url}/${var.project_id}/${var.repository_id}/${var.image_name}:${var.git_commit_sha}"
      ports {
        container_port = 3000
      }
    }
  }
  traffic {
    percent  = 100
    revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "noauth" {
  location    = google_cloud_run_v2_service.default.location
  project     = google_cloud_run_v2_service.default.project
  name        = google_cloud_run_v2_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
