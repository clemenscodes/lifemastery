resource "google_service_account" "cloud_run_service_account" {
  account_id  = var.project_name
  description = "The service account that will be used by the Cloud Run instance. Needs access to Cloud Storage"
}

module "project_iam_bindings_cloud_run_service_account" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  mode     = "authoritative"
  bindings = {
    "roles/storage.objectAdmin" = ["serviceAccount:${google_service_account.cloud_run_service_account.email}"]
    "roles/storage.admin"       = ["serviceAccount:${google_service_account.cloud_run_service_account.email}"]
  }
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
