output "cluster_id" {
  description = "EKS Cluster ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS Cluster API Server Endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Certificate Authority Data cua EKS Cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_arn" {
  description = "ARN cua EKS Cluster"
  value       = aws_eks_cluster.this.arn
}

output "node_group_arn" {
  description = "ARN cua Node Group"
  value       = aws_eks_node_group.this.arn
}
