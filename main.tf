terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "starter-kit-terraform-experiments"
    key    = "terraform-state"
    region = "ap-southeast-1"
    dynamodb_table = "starter-kit-terraform-experiments-lock"
  }
}

provider "aws" {
  region = "ap-southeast-1"
}
