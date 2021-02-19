variable "bucket" {
  type = string
  description = "S3 bucket for artifact storage."
  validation {
      condition = length(var.bucket) > 0
      error_message = "An S3 bucket is required."
  }
}