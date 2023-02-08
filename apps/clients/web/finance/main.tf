resource "google_project" "finance-development" {
  name       = "finance-development"
  project_id = "finance-development-375914"
  org_id     = "38836120782"
  folder_id  = google_folder.finance.name
}

resource "google_folder" "finance" {
  display_name = "finance"
  parent       = "organizations/38836120782"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "finance"
  location = "europe-west1"

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
  repository_id = "finance"
  format        = "DOCKER"
}
