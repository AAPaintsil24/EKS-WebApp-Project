variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/25" # 128 IPs
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.0.1/28", "10.0.0.16/28"]  # 16 IPs each
}

variable "private_k8s_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.0.32/27", "10.0.0.64/27"]  # 32 IPs each
}

variable "private_db_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.0.96/28", "10.0.3.112/28"]  # 16 IPs each
}

variable "name_prefix" {
  type    = string
  default = "albert"
}