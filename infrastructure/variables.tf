variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "environment" {
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

# Database variables
variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type      = string
  sensitive = true
  default   = "admin"
}


variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "15.4"
}

variable "db_multi_az" {
  type    = bool
  default = false
}