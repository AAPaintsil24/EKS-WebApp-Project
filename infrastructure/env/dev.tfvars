aws_region = "eu-north-1"
environment = "dev"
vpc_cidr = "10.0.0.0/25"
availability_zones = ["eu-north-1a", "eu-north-1b"]
public_subnets_cidrs = ["10.0.0.1/28", "10.0.0.16/28"]
private_k8s_subnets_cidrs = ["10.0.0.32/27", "10.0.0.64/27"]
private_db_subnets_cidrs = ["10.0.0.96/28", "10.0.3.112/28"]
name_prefix = "albertdev"

# Database configuration
db_name            = "albertdb"
db_username        = "admin"
db_password        = ""  # Will use Secrets Manager
db_instance_class  = "db.t3.micro"
db_engine          = "postgres"
db_engine_version  = "15.4"
db_multi_az        = false


kubernetes_version = "1.34"