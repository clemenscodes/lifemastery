variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}

variable "domain" {
  default = "lifemastery.tech"
}

variable "project_id" {
  default = "landing-production-375914"
}

variable "project_name" {
  default = "landing-production"
}

variable "folder_name" {
  default = "landing"
}

variable "workload_identity_service_account_id" {
  default = "gh-actions"
}

variable "workload_identity_provider_pool_id" {
  default = "github"
}

variable "workload_identity_pool_id" {
  default = "gh-workload-identity"
}

variable "region" {
  default = "europe-west3"
}

variable "owner" {
  default = "clemenscodes"
}

variable "repo" {
  default = "lifemastery"
}
