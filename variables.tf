variable "git_commit_sha" {
    description = "The git commit which will be used as the tag for the image"
    type = string
}

variable "region" {
    default = "europe-west3"
}
