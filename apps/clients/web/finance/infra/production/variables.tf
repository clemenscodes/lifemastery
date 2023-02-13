variable "project_name" {
  default = "finance-production"
}

variable "project_id" {
  default = "finance-production-375914"
}

variable "state_bucket" {
  default = "finance-production-state"
}

variable "isr_bucket" {
  default = "finance-production-isr"
}

variable "cdn_bucket" {
  default = "finance-production-cdn"
}

variable "subdomain" {
  default = "static.finance"
}

variable "cdn_region" {
  default = "europe-west3"
}

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}
