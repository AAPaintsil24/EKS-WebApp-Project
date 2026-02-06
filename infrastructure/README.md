# Infrastructure Terraform Modules

This repository contains the Terraform configuration for provisioning the cloud infrastructure for the Albert application stack, including **VPC**, **EKS Kubernetes cluster**, and **RDS database**, with environment-specific configurations for `dev` and `prod`.

Infrastructure provisioning is **stateless** and **modular**, following **12-factor principles**, making it suitable for automation via CI/CD pipelines (e.g., GitHub Actions with OIDC authentication).
