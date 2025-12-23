# resource "aws_db_subnet_group" "private" {
#   name       = "${var.name_prefix}-db-subnet-group"
#   subnet_ids = local.db_subnet_ids

#   tags = {
#     Name = "${var.name_prefix}-db-subnet-group"
#   }
# }


# #########################################
# # Generate a secure DB password
# #########################################
# resource "random_password" "db_instance" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

# #########################################
# # Store password in Secrets Manager
# #########################################
# resource "aws_secretsmanager_secret" "db_password" {
#   name = "${var.name_prefix}-db-password"
#   description = "RDS password for ${var.name_prefix} database"
#   recovery_window_in_days = 7
# }

# resource "aws_secretsmanager_secret_version" "db_password_version" {
#   secret_id     = aws_secretsmanager_secret.db_password.id
#   secret_string = random_password.db_instance.result
# }

# #########################################
# # RDS Multi-AZ instance
# #########################################
# resource "aws_db_instance" "main" {
#   identifier             = "${var.name_prefix}-rds"
#   engine                 = "mysql"
#   engine_version         = "8.0"
#   instance_class         = "db.t3.micro"
#   allocated_storage      = 20
#   storage_type           = "gp3"
#   username               = "albert"
#   password               = jsondecode(aws_secretsmanager_secret_version.db_password_version.secret_string)
#   db_name                = "mydb"
#   multi_az               = true
#   publicly_accessible    = false
#   vpc_security_group_ids = [aws_security_group.database.id]
#   db_subnet_group_name   = aws_db_subnet_group.private.name
#   skip_final_snapshot    = true
#   backup_retention_period = 7
#   auto_minor_version_upgrade = true

#   tags = {
#     Name = "${var.name_prefix}-rds"
#   }
# }

# #############################################
# # Local Variables for DB Subnet Group (Last Two Private Subnets)
# #############################################
#   private_subnet_keys       = keys(aws_subnet.private)
#   db_subnet_keys            = slice(local.private_subnet_keys, length(local.private_subnet_keys) - 2, length(local.private_subnet_keys))
#   db_subnet_ids             = [for k in local.db_subnet_keys : aws_subnet.private[k].id]


