variable "region" {
  type    = string
  default = "us-west-2"
  description = "The AWS region to use."
}

variable "scm_repository" {
  type = string
  default = "goof"
  description = "The SCM repository name."
}

variable "scm_branch" {
  type = string
  default = "master"
  description = "The SCM repository branch to use."
}

variable "snyk_orgid" {
  type = string
  description = "The Snyk Org ID which should be used"

  validation {
    condition = can(regex("^[A-Fa-f0-9]{8}\\-[A-Fa-f0-9]{4}\\-[A-Fa-f0-9]{4}\\-[A-Fa-f0-9]{4}\\-[A-Fa-f0-9]{12}$", var.snyk_orgid))
    error_message = "The snyk_orgid value must be in a valid format: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'."
  }
}

