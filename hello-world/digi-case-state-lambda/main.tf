terraform {
  backend "s3" {
    skip_region_validation = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }

  #required_version = "~>1.6.6"
}

provider "aws" {
  region = var.aws_region
}