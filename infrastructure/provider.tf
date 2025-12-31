terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-backend-albert"
    region         = "eu-north-1"
    encrypt        = true
    use_lockfile   = true
  }
    
    
  }
provider "aws" {
  region = var.aws_region
}
