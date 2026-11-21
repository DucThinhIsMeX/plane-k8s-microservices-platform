# S3 Bucket lưu trữ tài liệu, ảnh đính kèm và avatars của hệ thống Plane
# Sử dụng terraform_data để tương thích hoàn toàn với AWS Learner Lab SCP (chặn s3:GetBucketObjectLockConfiguration)
resource "terraform_data" "s3_bucket" {
  input = var.bucket_name

  provisioner "local-exec" {
    command     = "aws s3api create-bucket --bucket ${var.bucket_name} --region us-east-1 2>$null; exit 0"
    interpreter = ["powershell", "-Command"]
  }
}

