resource "aws_s3_bucket" "codeBuild" {
  bucket = var.bucket
  acl    = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm = "aws:kms"
      }
    }
  }
}

output "artifact_bucket" {
  value = aws_s3_bucket.codeBuild.bucket
}

output "codebuild_arn" {
  value = aws_s3_bucket.codeBuild.arn
}

resource "aws_iam_role" "codeBuildRole" {
  name = "snyk_codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com",
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

output "role_arn" {
  value = aws_iam_role.codeBuildRole.arn
}

resource "aws_iam_role_policy" "codeBuildRolePolicy" {
  role = aws_iam_role.codeBuildRole.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:GetAuthorizationToken",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ssm:GetParam*",
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:BatchGetBuildBatches",
        "codebuild:StartBuildBatch"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:Put*"
      ],
      "Resource": [
        "${aws_s3_bucket.codeBuild.arn}",
        "${aws_s3_bucket.codeBuild.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateData*"
      ],
      "Resource": "${var.kms_key_arn}"
    }
  ]
}
POLICY
}

resource "aws_ssm_parameter" "snyk_token" {
  name  = "snyk_token"
  type  = "String"
  value = var.snyk_api_token
}

resource "aws_ssm_parameter" "snyk_orgid" {
  name  = "snyk_orgid"
  type  = "String"
  value = var.snyk_orgid
}

resource "aws_codebuild_project" "snyk_goof_build" {
  name         = "snyk-goof-build"
  description  = "Snyk Goof Build Project"
  service_role = aws_iam_role.codeBuildRole.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.codeBuild.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "SNYK_TOKEN"
      value = aws_ssm_parameter.snyk_token.name
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "SNYK_ORG"
      value = aws_ssm_parameter.snyk_orgid.name
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "IMAGE_REPO"
      value = var.image_repo_name
    }
  }


  logs_config {
    cloudwatch_logs {
      group_name = "CodeBuildLogGroup"
    }
  }

  source {
    type            = "CODEPIPELINE"
    location        = var.scm_url
    git_clone_depth = 1
  }
}
