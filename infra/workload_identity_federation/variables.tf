variable "domain" {
  default = "lifemastery.tech"
}

variable "repo_owner" {
  default = "clemenscodes"
}

variable "repo" {
  default = "lifemastery"
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

variable "workload_identity_pool_id" {
  default = "gh-workload-identity"
}

variable "workload_identity_provider_pool_id" {
  default = "github"
}
