resource "google_artifact_registry_repository" "default" {
  format        = "DOCKER"
  location      = var.location
  project       = var.project
  repository_id = var.repository_id
}
