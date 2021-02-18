resource "aws_codecommit_repository" "goof" {
  repository_name = var.repository_name
  description     = "This is the Goof App Repository"
}