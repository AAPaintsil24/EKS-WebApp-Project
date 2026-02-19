# Connection details for applications
output "db_endpoint" {
  description = "RDS instance endpoint (hostname:port)"
  value       = aws_db_instance.main.endpoint
}

output "db_address" {
  description = "RDS instance hostname (without port)"
  value       = aws_db_instance.main.address
  sensitive   = false
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

# Security group for EKS to reference
output "db_security_group_id" {
  description = "Security group ID of the RDS instance"
  value       = aws_security_group.rds.id
}

# Resource identifiers
output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_identifier" {
  description = "RDS instance identifier (name)"
  value       = aws_db_instance.main.identifier
}

# For subnet group reuse
output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "db_secret_arn" {
  description = "ARN of the database secret in Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.arn
  sensitive   = true
}

