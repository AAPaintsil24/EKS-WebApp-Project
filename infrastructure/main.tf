module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                  = var.vpc_cidr
  availability_zones        = var.availability_zones
  public_subnets_cidrs      = var.public_subnets_cidrs
  #private_k8s_subnets_cidrs = var.private_k8s_subnets_cidrs
  private_db_subnets_cidrs  = var.private_db_subnets_cidrs
  name_prefix               = var.name_prefix
}

# 2. EKS Module (Kubernetes Cluster)
module "eks" {
  source = "./modules/eks"
  
  # Basic identification (CORRECT)
  name_prefix = var.name_prefix
  environment = var.environment
  
  # Network from VPC (CORRECT)
  vpc_id                 = module.vpc.vpc_id
  private_k8s_subnet_ids = module.vpc.private_k8s_subnet_ids
  
  # EKS Configuration (CORRECT)
  kubernetes_version = var.kubernetes_version
}

# Generate random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

# Store in Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.name_prefix}-${var.environment}/rds/credentials"
  description = "Database credentials"
  
  tags = {
    Environment = var.environment
    Project     = var.name_prefix
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = var.db_engine
    port     = 5432
    dbname   = var.db_name
  })
}

# RDS Module - UPDATED to use generated password
module "rds" {
  source = "./modules/rds"
  
  name_prefix = var.name_prefix
  environment = var.environment
  
  vpc_id       = module.vpc.vpc_id
  db_subnet_ids = module.vpc.private_db_subnet_ids
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = random_password.db_password.result  # Use generated password
  
  instance_class = var.db_instance_class
  engine         = var.db_engine
  engine_version = var.db_engine_version
  
  multi_az = var.db_multi_az
}