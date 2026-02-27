variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
  default     = "eu-north-1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

#EKS Control Plane
variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.34"
}

variable "private_k8s_subnet_ids" {
  description = "Private K8s subnet IDs for EKS control plane"
  type        = list(string)
}

variable "addon_versions" {
  description = "Versions for EKS addons"
  type = object({
    coredns   = string
    kube_proxy = string
    vpc_cni   = string
  })
  default = {
    # These are compatible with Kubernetes 1.34
    # Check AWS docs for latest versions
    coredns   = "v1.11.1-eksbuild.4"
    kube_proxy = "v1.29.0-eksbuild.2"
    vpc_cni   = "v1.16.0-eksbuild.1"
  }
}

variable "local_ips" {
  description = "List of local IPs allowed to access the cluster API"
  type        = string
  default     = "102.176.75.66/32"
}