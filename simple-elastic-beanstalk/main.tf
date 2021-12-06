terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  backend "remote" {
    organization = "yuanruo-test"

    workspaces {
      name = "yuanruo-test"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile             = var.aws_profile
  region              = var.aws_region
  allowed_account_ids = [var.allowed_account_id] # Avoid nuking the wrong account
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "app"
  cidr = "10.0.0.0/16"

  azs             = var.aws_azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
  # elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24"]
  # redshift_subnets    = ["10.0.41.0/24", "10.0.42.0/24"]
  # intra_subnets       = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = true

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}
