terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.52.0"
    }
  }
}

module "finance-production" {
  source       = "../"
  project_id   = var.project_id
  state_bucket = var.state_bucket
}
