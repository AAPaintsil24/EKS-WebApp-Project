locals {
  # Determine database port based on engine type
  db_port = {
    "postgres"  = 5432
    "mysql"     = 3306
    "oracle"    = 1521
    "sqlserver" = 1433
    "mariadb"   = 3306
  }[var.engine]
  
  # Create consistent resource names
  resource_prefix = "${var.name_prefix}-${var.environment}"
  
  # Set deletion protection based on environment
  final_deletion_protection = var.environment == "prod" ? true : var.deletion_protection
  
  # Set backup retention based on environment
  backup_retention = var.environment == "prod" ? 30 : var.backup_retention_period
}