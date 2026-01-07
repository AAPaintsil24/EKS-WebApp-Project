output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_k8s_subnet_ids" {
  value = module.vpc.private_k8s_subnet_ids
}

output "private_db_subnet_ids" {
  value = module.vpc.private_db_subnet_ids
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
  sensitive   = false
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = module.rds.db_security_group_id
}

output "db_secret_arn" {
  description = "ARN of the database secret in Secrets Manager"
  value       = module.rds.db_secret_arn
  sensitive   = true
}