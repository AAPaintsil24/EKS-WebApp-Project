variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/22"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]  # 256 IPs each
}

variable "private_k8s_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.2.0/25", "10.0.2.128/25"]  # 128 IPs each
}

variable "private_db_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.3.0/25", "10.0.3.128/25"]  # 128 IPs each
}

variable "name_prefix" {
  type    = string
  default = "albert"
}
