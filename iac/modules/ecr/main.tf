resource "aws_ecr_repository" "snyk-goof" {
  name                 = var.image_repo_name
  image_tag_mutability = "MUTABLE"
}
