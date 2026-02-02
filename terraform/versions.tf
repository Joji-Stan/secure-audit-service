terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # En prod, on stockerait le "state" (la mémoire de Terraform) sur S3
  # backend "s3" { ... }
}

provider "aws" {
  region = var.aws_region
}