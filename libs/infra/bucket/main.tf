terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.52.0"
    }
  }
}

resource "google_storage_bucket" "state_bucket" {
  name                        = var.state_bucket
  location                    = "EU"
  force_destroy               = false
  uniform_bucket_level_access = true
  project                     = var.project_id
  storage_class               = "STANDARD"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "bucket" {
  account_id = "bucket"
  project    = var.project_id
}

module "project_iam_bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  mode     = "authoritative"
  bindings = {
    "roles/storage.objectAdmin" = ["serviceAccount:${google_service_account.bucket.email}"]
    "roles/storage.admin" = ["serviceAccount:${google_service_account.bucket.email}"]
  }
}
