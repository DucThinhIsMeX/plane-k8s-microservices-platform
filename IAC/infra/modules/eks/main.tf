resource "aws_eks_cluster" "this" {
  name     = "${var.name}-eks"
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.control_plane_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-eks"
    Environment = var.name
    ManagedBy   = "Terraform"
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  instance_types = var.instance_types
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "${var.name}-eks-node"
    Environment = var.name
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_eks_cluster.this
  ]
}
