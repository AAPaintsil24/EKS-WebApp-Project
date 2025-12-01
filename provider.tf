terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
  alias  = "primary"
}

# terraform {
#   backend "s3" {
#     bucket = "my-terraform-state-bucket"
#     key    = "albertdevops/terraform/statefile.tfstate"
#     region = "eu-north-1"
#     # ... other backend-specific configuration
#   }
# }
