variable "folder_name" {
  default = "finance"
}

variable "repository_id" {
  default = "docker"
}

variable "org_name" {
  default = "lifemastery.tech"
}

variable "cloud_run_region" {
  default = "europe-west1"
}

variable "cloud_run_service_name" {
  default = "finance"
}

variable "artifact_region" {
  default = "europe-west1"
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

variable "state_bucket" {
  description = "The name of the state bucket that will be created"
  type        = string
}

variable "isr_bucket" {
  description = "The name of the isr bucket that will be created"
  type        = string
}

variable "cdn_bucket" {
  description = "The name of the cdn bucket that will be created"
  type        = string
}

variable "project_id" {
  description = "The id of the project in which the buckets will be created"
  type        = string
}

variable "project_name" {
  description = "The name of the project in which the buckets will be created"
  type        = string
}

variable "subdomain" {
  description = "The subdomain that will be used for the CDN"
  type        = string
}

variable "cdn_region" {
  description = "The region in which the CDN will be created"
  type        = string
}
