terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      
      version = "~> 5.0" 
    }
  }

  # This ensures it stays on the modern 1.7+ branch but don't accidentally
  # jump to a future 2.0 version that might break VPC logic.
  required_version = ">= 1.7.0, < 2.0.0"
}


provider "aws" {
  region = "us-east-1"
}