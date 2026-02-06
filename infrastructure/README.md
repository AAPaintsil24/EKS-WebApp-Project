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

```
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
```
- `env/` : Environment-specific variables (dev / prod).  
- `modules/` : Reusable modules for VPC, EKS, RDS.  
- `main.tf` : Root module orchestration, linking submodules.  
- `provider.tf` : AWS provider and S3 remote backend configuration.  
- `variables.tf` : Global variables for root module.  
- `outputs.tf` : Root-level outputs for consumption by other stacks or CI/CD.  

## Terraform Backend & Providers

- **Backend**: AWS S3 with state locking enabled (DynamoDB lock optional).  
- **Provider**: AWS, configurable via `aws_region`.  

Remote state ensures safe collaboration and prevents conflicts in team or automated environments.  

**Example provider configuration (`provider.tf`):**
```hcl
terraform {
  required_version = ">= 1.5"

  backend "s3" {
    bucket         = "albert-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "albert-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
```
## Modules

### VPC

- Creates VPC, public subnets, private subnets (for EKS & RDS), Internet Gateway, NAT Gateway, and route tables.  
- Subnets are tagged for Kubernetes integration (`internal-elb` / `role/elb`).  
- **Outputs**: `vpc_id`, `public_subnet_ids`, `private_k8s_subnet_ids`, `private_db_subnet_ids`.  

### EKS

Provisions EKS cluster with:

- Private control plane endpoints  
- Worker node groups per AZ  
- OIDC identity provider for IAM Roles for Service Accounts (IRSA)  
- Addons: CoreDNS, kube-proxy, vpc-cni  
- Security groups for control plane, nodes, and ALB  
- Auto-scaling configuration (min/max/desired nodes)  

**IAM Roles**:

- Cluster role (EKS control plane)  
- Node role (EC2 worker nodes)  
- Custom policy for ALB management  

**Outputs**: Cluster name, ARN, endpoint, kubeconfig helper command, node group ARNs, security group IDs, OIDC provider ARN, addon versions, and network summary.  

### RDS

Deploys PostgreSQL database instance with:

- Encrypted storage (default `gp3`)  
- Optional Multi-AZ deployment for production  
- Subnet group across private DB subnets  
- Security group restricted to EKS nodes or specified SGs  
- Auto-generated secrets stored in AWS Secrets Manager  
- Optional final snapshot and deletion protection  

**Outputs**: DB endpoint, address, port, instance ID, security group ID, subnet group name, secret ARN.

## Environment Configuration

`env/dev.tfvars` and `env/prod.tfvars` define environment-specific values.

**Example `dev.tfvars`:**

```hcl
name_prefix           = "albertdev"
environment           = "dev"
vpc_cidr              = "10.0.0.0/25"
public_subnets_cidrs  = ["10.0.0.0/28", "10.0.0.16/28"]
private_k8s_subnets_cidrs = ["10.0.0.32/27", "10.0.0.64/27"]
private_db_subnets_cidrs  = ["10.0.0.96/28", "10.0.0.112/28"]
aws_region            = "eu-north-1"
db_username           = "admin"
db_password        = ""  # Will use Secrets Manager
```
- Production uses similar values with different name_prefix and security parameters.

## Outputs

**Network:** `vpc_id`, `public_subnet_ids`, `private_k8s_subnet_ids`, `private_db_subnet_ids`  

**EKS:** cluster name, ARN, endpoint, kubeconfig command, node group info, security groups, OIDC provider ARN  

**RDS:** endpoint, hostname, port, security group ID, secret ARN  

These outputs are useful for:

- Application deployment variables  
- CI/CD pipeline integration  
- Security and monitoring automation

## Provisioning Workflow

1. **Initialize Terraform:**

```bash
terraform init -backend-config="env/dev.tfvars"
```
2. **Plan:**
```bash
terraform plan -var-file="env/dev.tfvars"
```
3. **Apply:**
```bash
terraform apply -var-file="env/dev.tfvars"
```

> **Note:** Ensure database passwords are handled securely (via Secrets Manager or CI/CD secrets).

# CI/CD Considerations

GitHub Actions workflows will use OIDC authentication to assume AWS IAM roles.

**Benefits:**

- No long-lived AWS credentials in repos
- Fine-grained IAM permissions per environment
- Easy automation for plan and apply

**Key practices:**

- Store environment-specific TF variables in `env/` folder
- Use `terraform plan` as a separate workflow step
- Use `terraform apply` only on main branch or tagged releases
- Manage sensitive outputs (`db_secret_arn`, cluster CA data) securely

