variable "name" {
  description = "Tien to dat ten tai nguyen"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM Role ARN cho EKS Cluster (su dung LabRole trong Learner Lab)"
  type        = string
}

variable "node_role_arn" {
  description = "IAM Role ARN cho EKS Node Group (su dung LabRole trong Learner Lab)"
  type        = string
}

variable "subnet_ids" {
  description = "Danh sach Private Subnet IDs de dat cac Worker Nodes"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "Danh sach Subnet IDs cho EKS Control Plane (it nhat 2 AZs)"
  type        = list(string)
}

variable "cluster_version" {
  description = "Phien ban Kubernetes cho EKS"
  type        = string
  default     = "1.31"
}

variable "instance_types" {
  description = "Loai may chu cho Node Group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "So luong node mong muon"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "So luong node toi thieu"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "So luong node toi da"
  type        = number
  default     = 3
}
