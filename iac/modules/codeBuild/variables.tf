variable "bucket" {
  type        = string
  description = "S3 bucket for artifact storage."
  validation {
    condition     = length(var.bucket) > 0
    error_message = "An S3 bucket is required."
  }
}

variable "scm_url" {
  type        = string
  description = "GitHub URL"
  default     = "https://github.com/ericsmalling/goof.git"
}

variable "kms_key_arn" {
  type = string
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

variable "image_repo_name" {
  type = string
}