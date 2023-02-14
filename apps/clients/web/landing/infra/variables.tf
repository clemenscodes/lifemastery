variable "folder_name" {
  default = "landing"
}

variable "org_name" {
  default = "lifemastery.tech"
}

variable "billing_account" {
  default = "01D0FC-03F662-69E484"
}

variable "state_bucket" {
  description = "The name of the state bucket that will be created"
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
