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

variable "git_commit_sha" {
  description = "The git commit which will be used as the tag for the image"
  type        = string
}
