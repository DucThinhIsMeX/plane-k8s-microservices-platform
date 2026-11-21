output "edge_public_ip" {
  description = "IP public của edge (bastion)"
  value       = module.edge.public_ip
}

# ---------- AWS EKS Outputs ----------
output "eks_cluster_name" {
  description = "Tên của EKS Cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint API Server của EKS"
  value       = module.eks.cluster_endpoint
}

output "eks_update_kubeconfig_cmd" {
  description = "Lệnh cập nhật Kubeconfig trên máy cá nhân để kết nối tới EKS"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

# output "nlb_dns_name" {
#   description = "Địa chỉ truy cập ứng dụng"
#   value       = "http://${module.nlb.dns_name}"
# }
# 
# output "k8s_masters" {
#   value = module.k8s_nodes.masters
# }
# 
# output "k8s_workers" {
#   value = module.k8s_nodes.workers
# }

output "docker_hub_namespace" {
  description = "Docker Hub account chua image cua he thong"
  value       = var.docker_hub_username
}

output "rancher_url" {
  description = "Giao dien Web Dashboard cua Rancher"
  value       = "https://${aws_instance.rancher.public_ip}/dashboard"
}

# output "argocd_url" {
#   description = "Giao dien Web Dashboard cua ArgoCD (qua NLB)"
#   value       = "https://${module.nlb.dns_name}:30085"
# }

# ---------- AWS Native Services Outputs (RDS & S3) ----------
output "rds_endpoint" {
  description = "Host va Port de ket noi ung dung toi AWS RDS PostgreSQL"
  value       = module.rds.endpoint
}

output "rds_address" {
  description = "Hostname cua RDS PostgreSQL"
  value       = module.rds.address
}

output "rds_db_name" {
  description = "Ten co so du lieu cua Plane tren RDS"
  value       = module.rds.db_name
}

output "rds_username" {
  description = "Master username cua RDS PostgreSQL"
  value       = module.rds.username
}

output "s3_plane_assets_bucket" {
  description = "S3 Bucket luu tru attachment, avatar va static assets cua Plane"
  value       = module.s3_plane.bucket_name
}

output "secret_names" {
  value = module.secrets.secret_names
}

# output "ssh_hint" {
#   value = "ssh -F generated/ssh_config k8s-master"
# }
