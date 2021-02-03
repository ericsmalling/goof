resource "aws_kms_key" "snyk_kms" {
  description             = "snyk build key"
  deletion_window_in_days = 10
}

output "kms_key_arn" {
  value = aws_kms_key.snyk_kms.arn
}