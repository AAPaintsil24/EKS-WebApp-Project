# 🚀 Cloud-Native Microservices Platform on AWS (EKS + Terraform + GitOps)

## 📋 Overview
This project is a **production-grade cloud-native application platform** built using modern DevOps and infrastructure practices. It demonstrates how to design, deploy, and operate a scalable microservices system on AWS using:

- **React (Frontend)**
- **Node.js / Express (Backend API)**
- **PostgreSQL (RDS)**
- **Terraform (Infrastructure as Code)**
- **Kubernetes (EKS)**
- **Helm (Application Packaging)**
- **ArgoCD (GitOps Deployment)**
- **GitHub Actions (CI/CD Pipelines)**

The system is fully containerised, environment-aware (`dev` and `prod`), and follows **12-factor application principles**.

---

## 🧱 Architecture Overview

```
User (Browser)
   │
   ▼
Frontend (React + Nginx)
   │
   ▼
Backend (Node.js Auth API)
   │
   ▼
PostgreSQL (AWS RDS)
   │
   ▼
Kubernetes (EKS Cluster)
   │
   ▼
AWS Infrastructure (Provisioned via Terraform)
```

### Key Characteristics
- Stateless services
- Secure secrets management (AWS Secrets Manager + External Secrets)
- GitOps-based deployment with ArgoCD
- Infrastructure fully automated with Terraform
- CI/CD pipelines using GitHub Actions with OIDC authentication

---

## 📁 Project Structure

```
.
├── apps/                  # Application layer (frontend + backend)
├── infrastructure/        # Terraform IaC (VPC, EKS, RDS)
├── k8s/                   # Kubernetes + Helm + ArgoCD
├── .github/workflows/     # CI/CD pipelines
├── docs/                  # Additional documentation
└── README.md
```

---

## 🧩 Application Layer (`apps/`)

### Frontend
- React single-page application
- Served via Nginx
- Communicates with backend API

### Backend
- Node.js (Express) authentication service
- Handles:
  - User signup/login
  - Password hashing (bcrypt)
  - Database persistence

### Database
- PostgreSQL hosted on AWS RDS
- Credentials stored in AWS Secrets Manager

---

## ☁️ Infrastructure Layer (`infrastructure/`)

Provisioned using **Terraform modules**:

### Modules
- **VPC**
  - Public + private subnets
  - NAT Gateway, routing

- **EKS**
  - Managed Kubernetes cluster
  - OIDC provider for IAM Roles (IRSA)
  - Node groups and addons

- **RDS**
  - PostgreSQL instance
  - Encrypted storage
  - Secrets stored in AWS Secrets Manager

### Environments
- `dev`
- `prod`

Each environment is configured via:
```
infrastructure/env/dev.tfvars
infrastructure/env/prod.tfvars
```

---

## ☸️ Kubernetes Layer (`k8s/`)

### Helm Charts
- Parent chart orchestrates:
  - `auth-service`
  - `frontend`

### Features
- Internal service communication via ClusterIP
- ALB Ingress for external access
- ConfigMaps and Secrets injection
- External Secrets Operator integration

### Secrets Flow
```
AWS Secrets Manager
        ↓
External Secrets Operator
        ↓
Kubernetes Secret
        ↓
Application Pods (Environment Variables)
```

---

## 🔄 GitOps Deployment (ArgoCD)

- ArgoCD monitors `k8s/Helm`
- Automatically syncs changes to the cluster
- Declarative deployment model

Apply ArgoCD:
```bash
kubectl apply -f k8s/argocd.yml
```

---

## ⚙️ CI/CD Pipelines (`.github/workflows/`)

### Backend Pipeline
- Install dependencies
- Run tests (unit only)
- Build Docker image
- Push to Amazon ECR

### Frontend Pipeline
- Install dependencies
- Run tests
- Build Docker image
- Push to Amazon ECR

### Infrastructure Pipeline
- Terraform `plan`, `apply`, or `destroy`
- Uses OIDC authentication (no static credentials)
- Supports `dev` and `prod`

---

## 🔐 Security

- No hardcoded credentials
- AWS OIDC used for GitHub Actions authentication
- Secrets managed via AWS Secrets Manager
- Kubernetes uses External Secrets Operator
- Private subnets for sensitive resources (RDS, nodes)

---

## 🚀 Getting Started

### 1. Provision Infrastructure
```bash
cd infrastructure
terraform init
terraform plan -var-file="env/dev.tfvars"
terraform apply -var-file="env/dev.tfvars"
```

---

### 2. Deploy Application (Helm)
```bash
cd k8s
helm install my-app ./Helm --set global.environment=dev
```

---

### 3. Enable GitOps (ArgoCD)
```bash
kubectl apply -f k8s/argocd.yml
```

---

### 4. Run Locally (Optional)

#### Backend
```bash
cd apps/backend/auth-service
npm install
npm start
```

#### Frontend
```bash
cd apps/frontend
npm install
npm start
```

---

## 🌐 Networking

- Frontend exposed via AWS ALB (Ingress)
- Backend accessed internally via Kubernetes service
- Database isolated in private subnets

---

## 📊 Key Design Principles

- **Modularity** → Terraform modules & Helm charts  
- **Scalability** → Kubernetes auto-scaling  
- **Security** → Secrets + private networking  
- **Automation** → CI/CD pipelines  
- **GitOps** → ArgoCD-driven deployments  
- **Environment parity** → dev vs prod  

---

## 🎯 What This Project Demonstrates

- End-to-end cloud architecture design  
- Infrastructure as Code (Terraform)  
- Kubernetes production deployment (EKS)  
- Secure secrets management  
- CI/CD with GitHub Actions + OIDC  
- GitOps workflow with ArgoCD  
- Microservices architecture  

---

## 🔮 Future Improvements

- Add monitoring (Prometheus + Grafana)  
- Implement logging (ELK / Loki)  
- Add horizontal pod autoscaling (HPA)  
- Introduce service mesh (e.g., Istio)  
- Add canary deployments / blue-green strategy  
- Expand to multi-service architecture  

---

## 👨‍💻 Author

Built as a **production-style DevOps portfolio project** demonstrating real-world cloud engineering practices.