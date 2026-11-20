variable "bucket_name" {
  description = "Ten S3 bucket luu tru assets cho Plane"
  type        = string
}

variable "force_destroy" {
  description = "Cho phep xoa bucket khi con chua objects de de dang destroy lab"
  type        = bool
  default     = true
}
