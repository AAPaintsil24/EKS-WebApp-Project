aws_region = "eu-north-1"
environment = "dev"
vpc_cidr = "10.0.0.0/22"
availability_zones = ["eu-north-1a", "eu-north-1b"]
public_subnets_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]
private_k8s_subnets_cidrs = ["10.0.2.0/25", "10.0.2.128/25"]
private_db_subnets_cidrs = ["10.0.3.0/25", "10.0.3.128/25"]
name_prefix = "albertdev"

# Database configuration
db_name            = "appdb"
db_username        = "admin"
db_password        = ""  # Will use Secrets Manager
db_instance_class  = "db.t3.micro"
db_engine          = "postgres"
db_engine_version  = "15.4"
db_multi_az        = false