# -------------------------------------------------------
# REMOTE STATE - VPC
# -------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "tf-state-949474132570"
    key    = "eks/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# -------------------------------------------------------
# REMOTE STATE - IAM
# -------------------------------------------------------
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "tf-state-949474132570"
    key    = "eks/iam/terraform.tfstate"
    region = "us-east-1"
  }
}

# -------------------------------------------------------
# EKS CLUSTER
# -------------------------------------------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = data.terraform_remote_state.iam.outputs.cluster_role_arn

  vpc_config {
    subnet_ids              = concat(
      data.terraform_remote_state.vpc.outputs.public_subnet_ids,
      data.terraform_remote_state.vpc.outputs.private_subnet_ids
    )
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = var.tags
}

# -------------------------------------------------------
# EKS MANAGED NODE GROUP
# -------------------------------------------------------
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "node-group-1"
  node_role_arn   = data.terraform_remote_state.iam.outputs.node_role_arn
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = var.tags
}

# -------------------------------------------------------
# EKS ADDONS
# -------------------------------------------------------
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = data.terraform_remote_state.iam.outputs.ebs_csi_role_arn

  depends_on = [aws_eks_node_group.this]
}
