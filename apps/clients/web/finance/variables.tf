variable "org_name" {
  description = "The name of the organization"
  type        = string
}

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}

variable "service_name" {
  default = "finance"
}

variable "project_name" {
  default = "finance-development"
}

variable "project_id" {
  default = "finance-development-375914"
}

variable "subdomain" {
  default = "dev.static.finance"
}

variable "artifact-region" {
  default = "europe-west3"
}

variable "cloud_run_region" {
  default = "europe-west1"
}

variable "cloud_run_service_name" {
  default = "finance"
}
