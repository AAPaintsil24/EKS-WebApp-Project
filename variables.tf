variable "vpc_cidr" {
  description = "The VPC CIDR  range to use for the virtual network."
  type        = string
  default     = "10.0.0.0/23"
}
 variable "availability_zones" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
 }
 
variable "public_subnets_cidrs" {
  description = "The CIDR range to  use for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/26", "10.0.0.64/26"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR range to  use for private subnets"
  type        = list(string)
  default     = ["10.0.0.128/26", "10.0.0.192/26", "10.0.1.0/26", "10.0.1.64/26"]
}


variable "instance_type" {
  description = "The  AWS Instance Type we want to launch."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The key pair name to use for the instance."
  type        = string
  default     = "albert_key"
}

variable "instance_count" {
  description = "The number of instances to launch."
  type        = number
  default     = 2
}

variable "instance_name" {
  description = "The name of the instance."
  type        = string
  default     = "albert-tf-ec2"
}

variable "name_prefix" {
  description = "This prefix will be added to the name of almost every resource created."
  type        = string
  default     = "albert"
}



