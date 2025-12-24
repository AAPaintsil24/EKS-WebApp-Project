terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "my-terraform-backend-albert"
    key    = "albertdevops/terraform/dev/statefile.tfstate"
    region = "eu-north-1"
  }
}

provider "aws" {
  region  = "eu-north-1"
  profile = "dev" # optional if using AWS CLI profile
}

