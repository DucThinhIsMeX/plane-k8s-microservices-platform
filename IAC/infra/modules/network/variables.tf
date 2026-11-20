variable "name" {
  description = "Tiền tố đặt tên"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "az" {
  description = "Availability Zone chính (AZ A)"
  type        = string
}

variable "az_b" {
  description = "Availability Zone phụ cho RDS Subnet Group (AZ B)"
  type        = string
  default     = "us-east-1b"
}

variable "vpc_cidr" {
  description = "CIDR của VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR private subnet A"
  type        = string
}

variable "private_subnet_b_cidr" {
  description = "CIDR private subnet B (cho RDS Multi-AZ Subnet Group)"
  type        = string
  default     = "10.0.12.0/24"
}
