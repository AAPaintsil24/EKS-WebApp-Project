locals {
  # Convert subnet map to list, sorted by key (AZ name)
  public_subnet_keys = sort(keys(aws_subnet.public))

  # First public subnet → Bastion host
  bastion_subnet_id = aws_subnet.public[local.public_subnet_keys[0]].id

  # Second public subnet →  NAT Gateway
  nat_subnet_id  = aws_subnet.public[local.public_subnet_keys[1]].id

  private_subnets = {
    "${var.availability_zones[0]}-app"  = var.private_subnet_cidrs[0]
    "${var.availability_zones[1]}-app"  = var.private_subnet_cidrs[1]
    "${var.availability_zones[0]}-db"   = var.private_subnet_cidrs[2]
    "${var.availability_zones[1]}-db"   = var.private_subnet_cidrs[3]
  }

  #############################################
  # Local Variables for DB Subnet Group (Last Two Private Subnets)
  #############################################
  private_subnet_keys       = keys(aws_subnet.private)
  db_subnet_keys            = slice(local.private_subnet_keys, length(local.private_subnet_keys) - 2, length(local.private_subnet_keys))
  db_subnet_ids             = [for k in local.db_subnet_keys : aws_subnet.private[k].id]

}
