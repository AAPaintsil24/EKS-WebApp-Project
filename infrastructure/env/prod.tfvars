aws_region = "eu-north-1"
name_prefix = "albert-prod"
vpc_cidr = "10.1.0.0/22"
availability_zones = ["eu-north-1a", "eu-north-1b"]
public_subnets_cidrs = ["10.1.0.0/25", "10.1.0.128/25"]
private_subnet_cidrs = ["10.1.1.0/25", "10.1.1.128/25", "10.1.2.0/25", "10.1.2.128/25"]
key_name = "albert_key_prod"
instance_type = "t3.medium"
