#!/bin/bash
echo "WARNING: This will delete the EKS cluster and all resources."
read -p "Type 'delete' to confirm: " confirm
if [ "$confirm" != "delete" ]; then
  echo "Cancelled."
  exit 1
fi

echo "Uninstalling Helm releases..."
helm uninstall web-app -n dev 2>/dev/null
helm uninstall web-app -n monitoring 2>/dev/null
helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null
helm uninstall kube-prometheus-stack -n monitoring 2>/dev/null

echo "Deleting any leftover security groups..."
VPC_ID=$(aws eks describe-cluster --name eks-fundamentals --query "cluster.resourcesVpcConfig.vpcId" --output text 2>/dev/null)
if [ -n "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
  SGS=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --region us-east-1 \
    --query "SecurityGroups[?GroupName!='default'].GroupId" \
    --output text)
  for SG in $SGS; do
    echo "Deleting security group $SG..."
    aws ec2 delete-security-group --group-id $SG --region us-east-1 2>/dev/null
  done

  echo "Deleting any leftover network interfaces..."
  ENIS=$(aws ec2 describe-network-interfaces \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --region us-east-1 \
    --query "NetworkInterfaces[].NetworkInterfaceId" \
    --output text)
  for ENI in $ENIS; do
    echo "Deleting network interface $ENI..."
    aws ec2 delete-network-interface --network-interface-id $ENI --region us-east-1 2>/dev/null
  done
fi

echo "Deleting EKS cluster..."
eksctl delete cluster --name eks-fundamentals --region us-east-1

echo "Done. Check AWS console to confirm all resources are removed."
