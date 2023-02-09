variable "domain" {
  default = "lifemastery.tech"
}

variable "default_region" {
  default = "europe-west3"
}

variable "default_project_id" {
  default = "landing-production-375914"
}

variable "default_project_name" {
  default = "landing-production"
}

variable "default_folder_name" {
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

variable "repo_owner" {
  default = "clemenscodes"
}

variable "repo" {
  default = "lifemastery"
}

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}
