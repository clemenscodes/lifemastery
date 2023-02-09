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
  project       = google_cloud_run_v2_service.default.project
  repository_id = var.repository_id
}

resource "google_cloud_run_v2_service" "default" {
  name     = var.cloud_run_service_name
  location = var.cloud_run_region
  project  = var.project_id
  template {
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"
    max_instance_request_concurrency = 80
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

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_v2_service.default.location
  project     = google_cloud_run_v2_service.default.project
  service     = google_cloud_run_v2_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
