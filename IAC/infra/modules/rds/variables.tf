variable "name" {
  description = "Tien to dat ten tai nguyen"
  type        = string
}

variable "subnet_ids" {
  description = "Danh sach private subnet IDs de tao DB Subnet Group (toi thieu 2 AZs)"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID cho phep ket noi toi PostgreSQL"
  type        = string
}

variable "instance_class" {
  description = "Instance type cho RDS PostgreSQL"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Dung luong khoi tao (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Dung luong toi da cho phep Storage Autoscaling (GB)"
  type        = number
  default     = 50
}

variable "db_name" {
  description = "Ten Database ban dau"
  type        = string
  default     = "plane"
}

variable "username" {
  description = "Master username cua PostgreSQL"
  type        = string
  default     = "plane_admin"
}

variable "password" {
  description = "Master password cua PostgreSQL"
  type        = string
  sensitive   = true
}
