variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}

variable "app" {
  default = "finance"
}

variable "development_project" {
  default = "finance-development-375914"
}

variable "production_project" {
  default = "finance-production-375914"
}

variable "region" {
  default = "europe-west3"
}

variable "apex" {
  default = "lifemastery.tech"
}

variable "dev" {
  default = "dev.static.finance"
}

variable "project_name" {
  default = "finance-development"
}

variable "project_id" {
  default = "finance-development-375914"
}

variable "org_id" {
  default = "38836120782"
}

variable "cloud_run_region" {
  default = "europe-west1"
}

variable "cloud_run_service_name" {
  default = "finance"
}
