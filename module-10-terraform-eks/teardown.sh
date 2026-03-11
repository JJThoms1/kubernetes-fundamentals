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
terraform destroy -auto-approve

echo "Destroying IAM module..."
cd ~/kubernetes-fundamentals/module-10-terraform-eks/iam
terraform destroy -auto-approve

echo "Destroying VPC module..."
cd ~/kubernetes-fundamentals/module-10-terraform-eks/vpc
terraform destroy -auto-approve

echo "Done."
