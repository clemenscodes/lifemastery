terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.52.0"
    }
  }
}

locals {
  ip_name         = "${var.bucket}-ip"
  url_map         = "${var.bucket}-https-lb"
  proxy_name      = "${local.url_map}-proxy"
  forwarding_rule = "${local.url_map}-forwarding-rule"
}

module "cdn_bucket" {
  source     = "../bucket/cdn_bucket"
  region     = var.region
  bucket     = var.bucket
  project_id = var.project_id
}
