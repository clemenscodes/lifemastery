variable "org_name" {
  description = "The name of the organization"
  type        = string
}

variable "folder_name" {
  description = "The name of the folder in which the project will be created"
  type        = string
}

variable "project_name" {
  description = "The name of the project in which the Cloud Run service will be created"
  type        = string
}

variable "project_id" {
  description = "The id of the project in which the Cloud Run service will be created"
  type        = string
}

variable "repository_id" {
  description = "The id of the repository in which the Docker image for the Cloud Run service will be created"
  type        = string
}

variable "cloud_run_region" {
  description = "The region in which the Cloud Run service will be created"
  type        = string
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service"
  type        = string
}

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}
