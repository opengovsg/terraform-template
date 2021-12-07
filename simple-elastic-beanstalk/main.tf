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
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"] # For load balancers
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]       # For app servers

  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
  # elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24"]
  # redshift_subnets    = ["10.0.41.0/24", "10.0.42.0/24"]
  # intra_subnets       = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"] # For internal workloads

  # Single NAT Gateway that will be deployed into the first public subnet
  # Alternative configurationss include one NAT Gateway per subnet (default) or one per AZ
  # See https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#nat-gateway-scenarios
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = true

  # BEGIN: for publicly accessible database
  # (not recommended for production)
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  # END: for publicly accessible database

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}
