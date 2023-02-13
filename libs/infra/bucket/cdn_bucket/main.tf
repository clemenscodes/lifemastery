resource "google_storage_bucket" "cdn_bucket" {
  name                        = var.bucket
  location                    = var.region
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
