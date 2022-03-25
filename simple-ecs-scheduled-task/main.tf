terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.00"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile             = var.aws_profile
  region              = var.aws_region
  allowed_account_ids = [var.allowed_account_id] # Avoid nuking the wrong account
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  task_name = "${var.app_name}-${terraform.workspace}-task"
  tags = {
    App       = var.app_name
    Terraform = "true"
    Workspace = terraform.workspace
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "3.5.0"

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

resource "aws_ecs_task_definition" "this" {
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

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = local.task_name
  schedule_expression = var.scheduled_task_schedule_expression
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = local.task_name
  arn       = module.ecs.ecs_cluster_arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.this.arn
    network_configuration {
      security_groups = var.scheduled_task_target_security_groups
      subnets = var.scheduled_task_target_subnets
    }
  }
}
