# Create DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "${var.name_prefix}-${var.environment}-db-subnet-group"
  subnet_ids  = var.db_subnet_ids
  
  tags = {
    Name        = "${var.name_prefix}-${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# Create Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-${var.environment}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-rds-sg"
    Environment = var.environment
  }
}

# Generate random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric           = true
  override_special = "!@#%&*()-_=+"
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
    engine   = var.engine
    port     = local.db_port
    dbname   = var.db_name
  })
}


# Create the RDS Database Instance
resource "aws_db_instance" "main" {
  identifier = "${var.name_prefix}-${var.environment}-db"
  
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted
  storage_type          = "gp3"
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password != null ? var.db_password : random_password.db_password.result
  port     = local.db_port
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  
  multi_az               = var.multi_az
  
  backup_retention_period = local.backup_retention
  
  skip_final_snapshot       = var.skip_final_snapshot
  deletion_protection       = local.final_deletion_protection
  
  tags = {
    Name        = "${var.name_prefix}-${var.environment}-db"
    Environment = var.environment
  }
}