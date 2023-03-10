resource "google_storage_bucket" "cdn_bucket" {
  name                        = var.bucket
  location                    = var.region
#   force_destroy               = false
  force_destroy               = true
  uniform_bucket_level_access = true
  project                     = var.project_id
  storage_class               = "STANDARD"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_storage_bucket_iam_binding" "bucket_read_access" {
  bucket  = google_storage_bucket.cdn_bucket.name
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}
