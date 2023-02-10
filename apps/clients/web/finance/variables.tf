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

variable "billing_account" {
  default = "01D0FC-03F662-69E484"
}

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "project_id" {
  description = "The id of the project"
  type        = string
}
