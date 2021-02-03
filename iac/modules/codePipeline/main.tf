resource "aws_codepipeline" "codepipeline" {
  name     = "snyk-goof-pipeline"
  role_arn = var.role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = [
        "source_output"]

      configuration = {
        "Branch"               = var.scm_repository_branch
        "Owner"                = var.scm_repository_owner
        "Repo"                 = var.scm_repository_repo
        "OAuthToken"           = var.github_oauth_token
        "PollForSourceChanges" = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = [
        "source_output"]
      output_artifacts = [
        "build_output"]
      version          = "1"
      configuration    = {
        ProjectName = "snyk-goof-build"
      }
    }
  }

}

resource "random_password" "webhook_secret" {
  length           = 32
  special          = true
  override_special = "_%@"
}
provider "github" {
  token        = var.github_oauth_token
  organization = var.scm_repository_owner
}

resource "aws_codepipeline_webhook" "goof-webhook" {
  authentication  = "GITHUB_HMAC"
  name            = "goof-github-webhook"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.codepipeline.name

  authentication_configuration {
    secret_token = random_password.webhook_secret.result
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

resource "github_repository_webhook" "goof-webhook" {
  repository = var.scm_repository_repo

  configuration {
    url          = aws_codepipeline_webhook.goof-webhook.url
    content_type = "json"
    insecure_ssl = true
    secret       = random_password.webhook_secret.result
  }

  events = [
    "push"]
}
