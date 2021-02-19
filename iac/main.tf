terraform {
  required_providers {
    aws = {
      version = "~> 2.67"
    }
  }
}

provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length = 8
  #require_lowercase_characters   = true
  #require_numbers                = true
  #require_uppercase_characters   = true
  #require_symbols                = true
  #allow_users_to_change_password = true
  #password_reuse_prevention      = 24 
  max_password_age = 3
}

module "vpc" {
  source = "./modules/vpc"
}

module "pki" {
  source = "./modules/pki"
}

module "codeCommit" {
  source = "./modules/codeCommit"
  repository_name = var.scm_repository
}