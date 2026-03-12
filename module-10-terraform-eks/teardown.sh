#!/bin/bash
set -e

echo "WARNING: This will delete the Terraform EKS cluster and all resources."
read -p "Type 'delete' to confirm: " confirm
if [ "$confirm" != "delete" ]; then
  echo "Aborted."
  exit 1
fi

echo "Uninstalling Helm releases..."
helm uninstall web-app -n dev 2>/dev/null || true
helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null || true
helm uninstall kube-prometheus-stack -n monitoring 2>/dev/null || true

echo "Waiting for NLBs to be deleted..."
sleep 30

echo "Destroying cluster module..."
cd ~/kubernetes-fundamentals/module-10-terraform-eks/cluster
terraform destroy -auto-approve || true

echo "Cleaning up IAM resources..."
aws iam detach-role-policy --role-name eks-fundamentals-node-role --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy 2>/dev/null || true
aws iam detach-role-policy --role-name eks-fundamentals-node-role --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy 2>/dev/null || true
aws iam detach-role-policy --role-name eks-fundamentals-node-role --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly 2>/dev/null || true
aws iam detach-role-policy --role-name eks-fundamentals-node-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy 2>/dev/null || true
aws iam detach-role-policy --role-name eks-fundamentals-cluster-role --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy 2>/dev/null || true
aws iam detach-role-policy --role-name eks-fundamentals-ebs-csi-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy 2>/dev/null || true
aws iam delete-role --role-name eks-fundamentals-node-role 2>/dev/null || true
aws iam delete-role --role-name eks-fundamentals-cluster-role 2>/dev/null || true
aws iam delete-role --role-name eks-fundamentals-ebs-csi-role 2>/dev/null || true
OIDC_ARN=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?contains(Arn, 'eks')].Arn" --output text 2>/dev/null || true)
[ -n "$OIDC_ARN" ] && aws iam delete-open-id-connect-provider --open-id-connect-provider-arn $OIDC_ARN 2>/dev/null || true

echo "Cleaning up leftover security groups..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=eks-fundamentals-vpc" --query "Vpcs[0].VpcId" --output text 2>/dev/null || true)
if [ -n "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
  for SG in $(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text); do
    aws ec2 delete-security-group --group-id $SG 2>/dev/null || true
  done
fi

echo "Destroying VPC module..."
cd ~/kubernetes-fundamentals/module-10-terraform-eks/vpc
terraform destroy -auto-approve

echo "Done. All resources destroyed."
