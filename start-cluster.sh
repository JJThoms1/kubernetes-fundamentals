#!/bin/bash
echo "Stopping any existing colima instance..."
colima stop 2>/dev/null
colima delete -f 2>/dev/null

echo "Starting colima..."
colima start --cpus 4 --memory 4 --disk 40

echo "Starting minikube..."
minikube start --driver=docker --cpus=4 --memory=3500

echo "Cluster ready."
kubectl get nodes
