variable "git_commit_sha" {
    description = "The git commit which will be used as the tag for the image"
    type = string
}

variable "project" {
    default = "landing-production-375914"
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
