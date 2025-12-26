locals {
  public_subnet_keys = sort(keys(aws_subnet.public))

  bastion_subnet_id = aws_subnet.public[local.public_subnet_keys[0]].id
  nat_subnet_id     = aws_subnet.public[local.public_subnet_keys[1]].id

  private_subnets = {
    "${var.availability_zones[0]}-k8s" = var.private_k8s_subnets_cidrs[0]
    "${var.availability_zones[1]}-k8s" = var.private_k8s_subnets_cidrs[1]
    "${var.availability_zones[0]}-db"  = var.private_db_subnets_cidrs[0]
    "${var.availability_zones[1]}-db"  = var.private_db_subnets_cidrs[1]
  }
}

