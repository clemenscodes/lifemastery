resource "google_folder" "default" {
  display_name = var.folder_name
  parent       = var.org_name
}

resource "google_project" "default" {
  name       = var.project_name
  project_id = var.project_id
  org_id     = var.org_name
  folder_id  = google_folder.default.name
}

resource "google_cloud_run_v2_service" "default" {
  name     = var.cloud_run_service_name
  location = var.cloud_run_region
  project  = google_project.default.project_id
  template {
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"
    max_instance_request_concurrency = 80
    scaling {
      min_instance_count = 0
      max_instance_count = 1000
    }
    containers {
      image = "europe-west3-docker.pkg.dev/finance-development-375914/finance/web:${var.git_commit_sha}"
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

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_v2_service.default.location
  project     = google_cloud_run_v2_service.default.project
  service     = google_cloud_run_v2_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_artifact_registry_repository" "default" {
  location      = google_cloud_run_v2_service.default.location
  project       = google_cloud_run_v2_service.default.project
  repository_id = var.repository_id
  format        = "DOCKER"
}
