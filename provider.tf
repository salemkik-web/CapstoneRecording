terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"
    }
  }
}

# Creating a VPC with minimal settings
provider "aws" {
  region = var.aws_region
}