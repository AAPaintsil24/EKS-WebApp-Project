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


# RDS Module - UPDATED to use generated password
module "rds" {
  source = "./modules/rds"
  
  name_prefix = var.name_prefix
  environment = var.environment
  
  vpc_id       = module.vpc.vpc_id
  db_subnet_ids = module.vpc.private_db_subnet_ids
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password 
  
  instance_class = var.db_instance_class
  engine         = var.db_engine
  engine_version = var.db_engine_version
  
  multi_az = var.db_multi_az
}