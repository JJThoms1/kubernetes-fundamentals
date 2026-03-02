#!/bin/bash
echo "WARNING: This will delete the EKS cluster and all resources."
read -p "Type 'delete' to confirm: " confirm
if [ "$confirm" != "delete" ]; then
  echo "Cancelled."
  exit 1
fi

echo "Uninstalling Helm releases..."
helm uninstall web-app -n dev 2>/dev/null
helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null

echo "Deleting EKS cluster..."
eksctl delete cluster --name eks-fundamentals --region us-east-1

echo "Done. Check AWS console to confirm all resources are removed."
