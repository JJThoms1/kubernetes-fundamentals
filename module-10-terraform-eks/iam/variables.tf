variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-fundamentals"
}

variable "tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    Project   = "kubernetes-fundamentals"
    ManagedBy = "terraform"
    Module    = "module-10-terraform-eks"
  }
}
