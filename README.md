# Kubernetes Fundamentals Project

A hands-on Kubernetes project built on a local minikube cluster demonstrating core concepts used in production environments.

## Tools

- Kubernetes 1.35.1 via minikube
- kubectl 1.34.1
- Helm 3.19.0
- Docker via Colima

## Project Structure
```
kubernetes-fundamentals/
├── module-1-core/          Deployment and Service
├── module-2-config/        ConfigMap and Secret
├── module-3-namespaces/    Namespaces and RBAC
├── module-4-health/        Health checks and HPA
├── module-5-storage/       PersistentVolume and PVC
└── module-6-helm/          Helm chart packaging
```

## Modules

### Module 1: Core Objects
Deployed a 3-replica nginx application using a Deployment and exposed it with a NodePort Service. Demonstrated self-healing by deleting a pod and watching Kubernetes replace it in under 10 seconds with zero downtime.

### Module 2: Configuration
Injected non-sensitive configuration via ConfigMap and sensitive credentials via Secret as environment variables into the running pods. Demonstrated live config updates using kubectl patch and rolling restart without rebuilding the container image.

### Module 3: Namespaces and RBAC
Created isolated dev and prod namespaces on the same cluster. Configured separate ServiceAccounts with Role and RoleBinding objects. Dev has full read/write access. Prod is read-only. Verified with kubectl auth can-i.

### Module 4: Health Checks and Autoscaling
Added liveness, readiness, and startup probes to the deployment. Enabled the metrics-server addon and configured a HorizontalPodAutoscaler to scale between 2 and 6 pods at 50% CPU utilization. Demonstrated automatic container restart after process failure.

### Module 5: Storage
Provisioned a 1Gi PersistentVolume and bound it via a PersistentVolumeClaim. Mounted the volume into the pod at /data. Demonstrated data persistence by writing a file, deleting the pod, and reading the same file from the replacement pod.

### Module 6: Helm
Packaged all Kubernetes objects into a Helm chart with a single values.yaml controlling all configuration. Demonstrated the full release lifecycle: install, upgrade with --set flags, rollback to a previous revision, and full release history tracking.

## Key Concepts Demonstrated

- Self-healing and automatic pod replacement
- Runtime configuration injection without image rebuilds
- Namespace isolation and RBAC enforcement
- Liveness and readiness probe behavior
- Horizontal pod autoscaling based on CPU metrics
- Data persistence across pod restarts
- Helm release management and rollback

## How to Run

### Prerequisites
- macOS with Homebrew
- colima, docker, minikube, kubectl, helm installed

### Start the cluster
```bash
./start-cluster.sh
```

### Deploy with Helm
```bash
helm install web-app ./module-6-helm/web-app --namespace dev
```

### Verify
```bash
kubectl get all -n dev
helm list -n dev
```

### Clean up
```bash
helm uninstall web-app --namespace dev
minikube delete
```
