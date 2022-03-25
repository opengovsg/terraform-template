terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
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
  tags = {
    App       = var.app_name
    Terraform = "true"
    Workspace = terraform.workspace
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = "${var.app_name}-${terraform.workspace}"
  container_insights = true
  capacity_providers = var.capacity_providers
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
    }
  ]
  tags = local.tags
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family = "${var.app_name}-${terraform.workspace}-task-definition"
  requires_compatibilities = ["FARGATE"]
  cpu = 1024
  memory = 2048
  network_mode = "awsvpc"
  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-${terraform.workspace}-task-container"
      image     = "${var.image}"
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
  }
}