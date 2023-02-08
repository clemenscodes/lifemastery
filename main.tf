terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.52.0"
    }
  }
}

provider "google" {
    region = var.region
}

module "finance" {
  source = "./apps/clients/web/finance"
  git_commit_sha = var.git_commit_sha
}

module "landing" {
  source = "./apps/clients/web/landing"
}
