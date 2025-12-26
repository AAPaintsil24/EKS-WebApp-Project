variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "env" {
  description = "Environment (dev or prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zones" {
  description = "List of AZs to use"
  type        = list(string)
}

variable "public_subnets_cidrs" {
  description = "Public subnets CIDR blocks"
  type        = list(string)
}

variable "private_k8s_subnets_cidrs" {
  description = "Private subnets CIDR blocks for K8s"
  type        = list(string)
}

variable "private_db_subnets_cidrs" {
  description = "Private subnets CIDR blocks for DB"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}



