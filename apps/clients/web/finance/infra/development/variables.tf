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

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}
