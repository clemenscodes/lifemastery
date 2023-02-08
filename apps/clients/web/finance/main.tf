provider "google" {
  project = "finance-production-375914"
}

resource "google_cloud_run_service" "default" {
  name                       = "finance"
  location                   = "europe-west1"
  autogenerate_revision_name = true

  metadata {
    annotations = {
      "autoscaling.knative.dev/maxScale" = "1000"
      "run.googleapis.com/client-name"   = "terraform"
    }
  }

  template {
    spec {
      containers {
        image = "europe-west3-docker.pkg.dev/finance-production-375914/finance/web:${var.git_commit_sha}"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }


}

data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
# resource "google_cloud_run_service" "finance-development" {
#   name     = "finance"
#   location = "europe-west1"

#   metadata {
#     namespace = "finance-production-375914"
#   }

#   traffic {
#     percent         = 100
#     latest_revision = true
#   }
# }
