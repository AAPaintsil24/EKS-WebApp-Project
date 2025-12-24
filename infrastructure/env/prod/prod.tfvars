# Prefix for resource names
name_prefix = "albert-prod"

# VPC
vpc_cidr = "10.1.0.0/22"

# Availability zones
availability_zones = ["eu-north-1a", "eu-north-1b"]

# Public subnets
public_subnets_cidrs = ["10.1.0.0/25", "10.1.0.128/25"]

# Private subnets
private_subnet_cidrs = ["10.1.1.0/25", "10.1.1.128/25", "10.1.2.0/25", "10.1.2.128/25"]

# Bastion Host
key_name = "albert_key_prod"
instance_type = "t3.medium"