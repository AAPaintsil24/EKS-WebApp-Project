module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                  = var.vpc_cidr
  availability_zones        = var.availability_zones
  public_subnets_cidrs      = var.public_subnets_cidrs
  private_k8s_subnets_cidrs = var.private_k8s_subnets_cidrs
  private_db_subnets_cidrs   = var.private_db_subnets_cidrs
  name_prefix               = var.name_prefix
}









