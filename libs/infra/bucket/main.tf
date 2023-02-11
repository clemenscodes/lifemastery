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
