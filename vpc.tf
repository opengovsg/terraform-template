module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "starter-kit-test"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  reuse_nat_ips      = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "starter-kit-test"
  }
}

# to-do: add dns query logging
resource "aws_flow_log" "example" {
  log_destination      = aws_s3_bucket.test_app_flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id
}

resource "aws_s3_bucket" "test_app_flow_logs" {
  bucket        = "starter-kit-test-flow-logs"
  force_destroy = true
}