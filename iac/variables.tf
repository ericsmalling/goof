variable "region" {
  type        = string
  default     = "us-west-2"
  description = "The AWS region to use."
}

variable "scm_repository_owner" {
  type        = string
  description = "The SCM repository account owner."

  validation {
    condition = length(var.scm_repository_owner) > 0
    error_message = "An SCM repo owner is required."
  }
}

variable "scm_repository_repo" {
  type        = string
  default     = "goof"
  description = "The SCM repository repo name."
}

variable "scm_repository_branch" {
  type        = string
  default     = "main"
  description = "The SCM repository branch to use."
}

variable "github_oauth_token" {
  type = string
  description = "A GitHub OAUTH Token must be set up and provided"

  validation {
    condition = can(regex("^[A-Fa-f0-9]{40}$", var.github_oauth_token))
    error_message = "This does not look like proper GitHum token format (40 hex chars)."
  }
}

variable "snyk_orgid" {
  type        = string
  description = "The Snyk Org ID used for snyk monitor"

  validation {
    condition     = can(regex("^[A-Fa-f0-9]{8}\\-[A-Fa-f0-9]{4}\\-[A-Fa-f0-9]{4}\\-[A-Fa-f0-9]{4}\\-[A-Fa-f0-9]{12}$", var.snyk_orgid))
    error_message = "The snyk_orgid value must be in a valid format: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'."
  }
}

variable "snyk_api_token" {
  type        = string
  description = "The Snyk API token used for snyk auth"
  validation {
    condition     = can(regex("^[A-Fa-f0-9]{8}\\-[A-Fa-f0-9]{4}\\-[A-Fa-f0-9]{4}\\-[A-Fa-f0-9]{4}\\-[A-Fa-f0-9]{12}$", var.snyk_api_token))
    error_message = "The snyk_api_token value must be in a valid format: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'."
  }
}

variable "artifact_bucket" {
  type        = string
  default     = "snyk-goof-build-artifacts-202102191838"
  description = "The S3 bucket to store codeBuild artifacts in."
  validation {
    condition     = length(var.artifact_bucket) > 0
    error_message = "An S3 bucket fore codeBuild artifacts is required."
  }

}

variable "image_repo_name" {
  type    = string
  default = "synk-goof"
}
