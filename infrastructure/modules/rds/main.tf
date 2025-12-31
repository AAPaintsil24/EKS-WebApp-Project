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
  password = var.db_password
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