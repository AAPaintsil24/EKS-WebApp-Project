# # 🚀 Project Infrastructure & Deployment

## 📋 Overview
This project contains a complete cloud-native application with:

- **AWS Infrastructure** (VPC, EKS, RDS) provisioned with Terraform  
- **Microservices** (Auth Service & Frontend) containerized with Docker  
- **Kubernetes manifests** managed with Helm  
- **CI/CD pipelines** with GitHub Actions  
- **GitOps deployment** with ArgoCD  

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                      GitHub Repository                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  Terraform   │    │   Docker     │    │     Helm     │  │
│  │Infrastructure│    │   Images     │    │   Manifests  │  │
│  └──────────────┘    └──────────────┘    └──────────────┘
```
# 🚀 Kubernetes Deployment

## 📋 Overview
This directory contains Kubernetes manifests for deploying the application on EKS using Helm.

## 📁 Structure
```
k8s/
├── Helm/                    # Parent Helm chart
│   ├── Chart.yaml           # Chart dependencies
│   ├── values.yaml          # Global values
│   ├── charts/              # Subcharts
│   │   ├── auth-service/    # Auth service chart
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   └── templates/
│   │   │       ├── _helpers.tpl
│   │   │       ├── configmap.yaml
│   │   │       ├── deployment.yaml
│   │   │       ├── externalsecret.yaml
│   │   │       └── service.yaml
│   │   └── frontend/        # Frontend chart
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── _helpers.tpl
│   │           ├── deployment.yaml
│   │           └── service.yaml
│   └── templates/           # Parent templates
│       ├── _helpers.tpl
│       └── ingress.yaml
└── argocd.yml               # ArgoCD application manifest
```
## 🚦 Prerequisites

- EKS cluster running
- External Secrets Operator installed
- AWS Load Balancer Controller installed

## 📦 Services

### Auth Service
- Port: 4000 (internal)
- DB: PostgreSQL (AWS RDS)
- Secrets: Pulled from AWS Secrets Manager via ExternalSecrets

### Frontend
- Port: 80 (internal)
- API: Calls `auth-service` internally at `{{ .Release.Name }}-auth-service:80`

## 🔧 Installation

### Local Development
```bash
# Install both services
helm install my-app ./Helm --set global.environment=dev

# Install with override
helm install my-app ./Helm --set auth-service.replicas=2
```

### Environment-specific
```bash
# Dev
helm install my-app ./Helm -f ./Helm/values.yaml --set global.environment=dev

# Prod
helm install my-app ./Helm -f ./Helm/values.yaml --set global.environment=prod
```

🔄 **GitOps with ArgoCD** 
```bash
# Apply ArgoCD application
kubectl apply -f argocd.yml
```
The ArgoCD manifest points to k8s/Helm and automatically syncs changes.

🌐 **Ingress**  
- Single ALB exposing frontend at `/`  
- Frontend internally calls `auth-service`  
- Configured for internet-facing access

🔐 **Secrets Management**  
- Uses External Secrets Operator to sync from AWS Secrets Manager:  
  - Dev: `dev/rds/credentials`  
  - Prod: `prod/rds/credentials`  

📝 **Notes**  
- All services use `ClusterIP` for internal communication  
- Frontend expects `AUTH_SERVICE_URL` environment variable  
- Auth Service expects DB credentials from mounted secrets
