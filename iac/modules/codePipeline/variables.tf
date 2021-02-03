variable "artifact_bucket" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "scm_repository_owner" {
  type = string
}

variable "scm_repository_repo" {
  type = string
}

variable "scm_repository_branch" {
  type = string
}

variable "github_oauth_token" {
  type = string
}

variable "codebuild_arn" {
  type = string
}