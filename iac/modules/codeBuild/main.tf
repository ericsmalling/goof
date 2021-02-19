resource "aws_s3_bucket" "codeBuild" {
  bucket = var.bucket
  acl    = "private"
  #todo: encrypt
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
        "Service": "codebuild.amazonaws.com"              
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
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
        "codecommit:GitPull",
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:UploadArchive",
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
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "snyk_goof_build" {
  name = "snyk-goof-build"
  description = "Snyk Goof Build Project"
  service_role = aws_iam_role.codeBuildRole.arn
  
  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "S3"
    location = aws_s3_bucket.codeBuild.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "CodeBuildLogGroup"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2
env:
parameter-store:
    SNYK_TOKEN: "snykAuthToken" #This parameter has to be created beforehand since SecureString type is not supported in CFN
    SNYK_ORG: "snykOrg" 
phases:
install:
    commands:
    - echo 'installing Snyk'
    - npm install -g snyk
pre_build:
    commands:
    - echo 'authorizing with Snyk'
    #- snyk auth
build:
    commands:
    - echo 'starting snyk scan'
    - cd cdk/products/env
    - pip install -r requirements_user_basic.txt
    - snyk monitor --file=requirements_user_basic.txt --package-manager=pip --org=$SNYK_ORG
post_build:
    commands:
    - echo ***** Build completed *****
EOF
  }
}







