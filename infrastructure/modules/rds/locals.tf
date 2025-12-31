locals {
  # Determine database port based on engine type
  db_port = var.engine == "postgres" ? 5432 : 
            var.engine == "mysql" ? 3306 : 
            var.engine == "oracle" ? 1521 : 
            var.engine == "sqlserver" ? 1433 : 
            var.engine == "mariadb" ? 3306 : 5432  # default to PostgreSQL
  
  # Create consistent resource names
  resource_prefix = "${var.name_prefix}-${var.environment}"
  
  # Set deletion protection based on environment
  final_deletion_protection = var.environment == "prod" ? true : var.deletion_protection
  
  # Set backup retention based on environment
  backup_retention = var.environment == "prod" ? 30 : var.backup_retention_period
  
  # Parameter group family (for future use if add parameter groups are added)
  parameter_group_family = var.engine == "postgres" ? "postgres${split(".", var.engine_version)[0]}${split(".", var.engine_version)[1]}" : 
                           var.engine == "mysql" ? "mysql${split(".", var.engine_version)[0]}${split(".", var.engine_version)[1]}" : null
}