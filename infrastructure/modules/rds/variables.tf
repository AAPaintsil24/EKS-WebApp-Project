variable "name_prefix" {
  description = "Prefix for all resource names (e.g., 'albertdev')"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}


variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "db_subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}


variable "db_name" {
  description = "Database name (the actual database inside the instance)"
  type        = string
  default     = "albertdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class (size)"
  type        = string
  default     = "db.t3.micro"
}

variable "engine" {
  description = "Database engine type"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.14"
}


variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling"
  type        = number
  default     = 100
}


variable "storage_encrypted" {
  description = "Whether to encrypt storage at rest"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}


variable "multi_az" {
  description = "Whether to deploy in Multi-AZ configuration"
  type        = bool
  default     = false
}


variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs that should have access to the database"
  type        = list(string)
  default     = []
}


variable "kms_key_id" {
  description = "KMS key ID for encryption. If not specified, uses default AWS RDS key"
  type        = string
  default     = null
}

