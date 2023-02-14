variable "project_name" {
  default = "finance-development"
}

variable "project_id" {
  default = "finance-development-375914"
}

variable "state_bucket" {
  default = "finance-development-state"
}

variable "isr_bucket" {
  default = "finance-development-isr"
}

variable "cdn_bucket" {
  default = "finance-development-cdn"
}

variable "cdn_subdomain" {
  default = "dev.static.finance"
}

variable "cloud_run_subdomain" {
  default = "dev.finance"
}

variable "cdn_region" {
  default = "europe-west3"
}

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}

variable "access_token" {
  description = "The access token which will be used for authenticating terraform in a CI/CD pipeline"
  type        = string
}
