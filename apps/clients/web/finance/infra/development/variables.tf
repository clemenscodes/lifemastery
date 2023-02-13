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

variable "subdomain" {
  default = "dev.static.finance"
}

variable "cdn_region" {
  default = "europe-west3"
}

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  default     = "finance-development-cdn"
  type        = string
}
