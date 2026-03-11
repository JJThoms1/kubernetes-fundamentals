output "cluster_role_arn" {
  description = "IAM role ARN for the EKS cluster"
  value       = aws_iam_role.eks_cluster.arn
}

output "node_role_arn" {
  description = "IAM role ARN for the EKS node group"
  value       = aws_iam_role.eks_node.arn
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN for EBS CSI driver IRSA"
  value       = aws_iam_role.ebs_csi.arn
}
