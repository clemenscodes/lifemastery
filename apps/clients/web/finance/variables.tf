variable "dev_project_name" {
  default = "finance-development"
}

variable "dev_project_id" {
  default = "finance-development-375914"
}

variable "prod_project_name" {
  default = "finance-production"
}

variable "prod_project_id" {
  default = "finance-production-375914"
}

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

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}
