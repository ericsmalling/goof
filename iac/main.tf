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

# module "iam" {
#   source = "./modules/iam"
# }

module "vpc" {
  source = "./modules/vpc"
}

module "pki" {
  source = "./modules/pki"
}

module "codeBuild" {
  source          = "./modules/codeBuild"
  bucket          = var.artifact_bucket
  kms_key_arn     = module.pki.kms_key_arn
  snyk_api_token  = var.snyk_api_token
  snyk_orgid      = var.snyk_orgid
  image_repo_name = var.image_repo_name
}

module "codePipeline" {
  source                = "./modules/codePipeline"
  artifact_bucket       = module.codeBuild.artifact_bucket
  role_arn              = module.codeBuild.role_arn
  kms_key_arn           = module.pki.kms_key_arn
  codebuild_arn         = module.codeBuild.codebuild_arn
  scm_repository_repo   = var.scm_repository_repo
  scm_repository_owner  = var.scm_repository_owner
  scm_repository_branch = var.scm_repository_branch
  github_oauth_token    = var.github_oauth_token
}

module "ecr" {
  source          = "./modules/ecr"
  image_repo_name = var.image_repo_name
}