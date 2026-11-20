output "bucket_name" {
  description = "Ten S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN cua S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Domain name cua S3 bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}
