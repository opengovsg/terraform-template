terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  backend "remote" {
    organization = "yuanruo-test" # TODO: remove

    workspaces {
      name = "yuanruo-test" # TODO: remove
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile             = var.aws_profile
  region              = var.aws_region
  allowed_account_ids = [var.allowed_account_id] # Avoid nuking the wrong account
}

locals {
  app_name    = "app"
  environment = "test"
  tags = {
    App         = local.app_name
    Terraform   = "true"
    Environment = local.environment
    Workspace   = terraform.workspace
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.app_name}-${local.environment}"
  cidr = "10.0.0.0/16"

  azs             = var.aws_azs
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"] # For load balancers
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]       # For app servers

  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"] # For primary + failover
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
  # (comment out this section for production environments)
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  # END: for publicly accessible database

  tags = local.tags
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "${local.app_name}-${local.environment}"
  description = "PostgreSQL security group for ${local.app_name}-${local.environment}"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.app_name}-${local.environment}"

  apply_immediately = true # Don't wait for maintenance window

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "13.4"
  family               = "postgres13" # DB parameter group
  major_engine_version = "13"         # DB option group
  instance_class       = "db.t3.micro"

  # Storage options
  allocated_storage     = 20    # GB
  max_allocated_storage = 100   # GB
  storage_encrypted     = true  # Uses default KMS key, if `kms_key_id` not set
  storage_type          = "gp2" # General purpose
  # iops = 0 # Setting this implies a storage_type of "io1" (provisioned IOPS SSD)

  # Credentials
  name     = "${local.app_name}${local.environment}"
  username = var.db_root_user
  password = var.db_root_password
  port     = 5432

  multi_az               = true
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.db_security_group.security_group_id]

  publicly_accessible = true # Not encouraged for production

  # Maintenance window
  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Backup configuration
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = true

  # Monitoring options
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "example-monitoring-role-name"
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
}

module "elastic_beanstalk_application" {
  source  = "cloudposse/elastic-beanstalk-application/aws"
  version = "0.11.1"
  # namespace   = "ogp"
  stage       = local.environment
  name        = local.app_name
  description = "Elastic Beanstalk application for ${local.app_name}-${local.environment}"
  tags        = local.tags
}

module "elastic_beanstalk_environment" {
  source = "cloudposse/elastic-beanstalk-environment/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  # namespace                          = var.namespace
  stage                      = local.environment
  name                       = local.app_name
  description                = "Elastic Beanstalk environment for ${local.app_name}-${local.environment}"
  region                     = var.aws_region
  availability_zone_selector = "Any 2"
  # dns_zone_id                        = var.dns_zone_id
  elastic_beanstalk_application_name = module.elastic_beanstalk_application.elastic_beanstalk_application_name

  instance_type           = "t3.micro"
  autoscale_min           = 1
  autoscale_max           = 1
  updating_min_in_service = 0
  updating_max_batch      = 1

  loadbalancer_type    = "application"
  vpc_id               = module.vpc.vpc_id
  loadbalancer_subnets = module.vpc.public_subnets
  application_subnets  = module.vpc.private_subnets
  security_group_rules = [
    {
      type                     = "egress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      description              = "Allow all outbound traffic"
    },
    # {
    #   type                     = "ingress"
    #   from_port                = 0
    #   to_port                  = 65535
    #   protocol                 = "-1"
    #   source_security_group_id = module.vpc.default_security_group_id
    #   cidr_blocks              = null
    #   description              = "Allow all ingress traffic from trusted Security Groups"
    # },
  ]
  prefer_legacy_service_policy = false

  // https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html
  // https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html#platforms-supported.docker
  solution_stack_name = "64bit Amazon Linux 2 v3.4.9 running Docker"

  additional_settings = [
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "DB_HOST"
      value     = "xxxxxxxxxxxxxx"
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "DB_USERNAME"
      value     = "yyyyyyyyyyyyy"
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "DB_PASSWORD"
      value     = "zzzzzzzzzzzzzzzzzzz"
    }
  ]
}
  