variable "folder_name" {
  default = "finance"
}

variable "repository_id" {
  default = "finance"
}

variable "cloud_run_region" {
  default = "europe-west1"
}

variable "cloud_run_service_name" {
  default = "finance"
}

variable "artifact_region" {
  default = "europe-west3"
}

variable "registry_url" {
  default = "docker.pkg.dev"
}

variable "image_name" {
  default = "web"
}

variable "org_name" {
  description = "The name of the organization"
  type        = string
}

variable "workflow_service_account_email" {
  description = "The email of the service account that will be used by GitHub actions workflow identity federation"
  type        = string
}

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}

variable "project_name" {
  description = "The name of the project to be created"
  type        = string
}

variable "project_id" {
  description = "The if of the project to be created"
  type        = string
}
