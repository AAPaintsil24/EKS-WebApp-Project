# Prefix for resource names
name_prefix = "albert-dev"

# VPC
vpc_cidr = "10.0.0.0/23"

# Availability zones
availability_zones = ["eu-north-1a", "eu-north-1b"]

# Public subnets
public_subnets_cidrs = ["10.0.0.0/26", "10.0.0.64/26"]

# Private subnets
private_subnet_cidrs = ["10.0.0.128/26", "10.0.0.192/26", "10.0.1.0/26", "10.0.1.64/26"]

# Bastion Host
key_name = "albert_key_dev"
instance_type = "t3.micro"