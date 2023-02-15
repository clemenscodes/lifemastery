terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.53.0"
    }
  }
}

module "landing" {
  source       = "../"
  project_name = var.project_name
  project_id   = var.project_id
  state_bucket = var.state_bucket
}
