output "bucket_name" {
  description = "Ten S3 bucket"
  value       = var.bucket_name
}

output "bucket_arn" {
  description = "ARN cua S3 bucket"
  value       = "arn:aws:s3:::${var.bucket_name}"
}

output "bucket_domain_name" {
  description = "Domain name cua S3 bucket"
  value       = "${var.bucket_name}.s3.amazonaws.com"
}
