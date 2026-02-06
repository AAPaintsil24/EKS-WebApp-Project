# Infrastructure Terraform Modules

This repository contains the Terraform configuration for provisioning the cloud infrastructure for the Albert application stack, including **VPC**, **EKS Kubernetes cluster**, and **RDS database**, with environment-specific configurations for `dev` and `prod`.

Infrastructure provisioning is **stateless** and **modular**, following **12-factor principles**, making it suitable for automation via CI/CD pipelines (e.g., GitHub Actions with OIDC authentication).

# Table of Contents

- [Architecture Overview](#architecture-overview)
- [Directory Structure](#directory-structure)
- [Terraform Backend & Providers](#terraform-backend--providers)
- [Modules](#modules)
  - [VPC](#vpc)
  - [EKS](#eks)
  - [RDS](#rds)
- [Environment Configuration](#environment-configuration)
- [Outputs](#outputs)
- [Provisioning Workflow](#provisioning-workflow)
- [CI/CD Considerations](#cicd-considerations)

## Architecture Overview

The infrastructure design includes:

- **VPC with 6 subnets:**
  - 2 Public (for NAT gateways and bastions)
  - 2 Private for EKS worker nodes
  - 2 Private for RDS databases

- **EKS Cluster**  
  Private control plane endpoint, OIDC provider for IAM roles, worker node groups across availability zones, and essential addons (CoreDNS, kube-proxy, vpc-cni).

- **RDS Database (PostgreSQL)**  
  Deployed in private subnets with encrypted storage, automated password management via Secrets Manager, optional Multi-AZ deployment for production, and security groups linked to EKS.

- **Stateless modules**  
  Configurable via environment variables (dev / prod).

### The design ensures:

- High availability (multi-AZ ready)  
- Private networking for sensitive components  
- Integration with CI/CD automation  
- Secure secrets handling


# Directory Structure

`
infrastructure/
│-- env/
│   ├─ dev.tfvars
│   └─ prod.tfvars
│-- modules/
│   ├─ vpc/
│   ├─ eks/
│   └─ rds/
│-- main.tf
│-- provider.tf
│-- variables.tf
│-- outputs.tf
`
- `env/` : Environment-specific variables (dev / prod).  
- `modules/` : Reusable modules for VPC, EKS, RDS.  
- `main.tf` : Root module orchestration, linking submodules.  
- `provider.tf` : AWS provider and S3 remote backend configuration.  
- `variables.tf` : Global variables for root module.  
- `outputs.tf` : Root-level outputs for consumption by other stacks or CI/CD.  
