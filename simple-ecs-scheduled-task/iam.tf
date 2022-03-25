// IAM Resources
// -------------
// We create 2 IAM roles:
// 1. A Task Execution role used to run the ECS task and log output to cloudwatch.  This can be overridden by the user if they are using a
//    non-default ECSTaskExecutionRole.
// 2. A second role used by Cloudwatch to launch the ECS task when the timer is triggered
//
// Users can add a 3rd role if the ECS Task needs to access AWS resources.

// Task Execution Role
// Includes essential ecs access and cloudwatch logging permissions
data "aws_iam_policy_document" "task_execution_assume_role" {
  statement {
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

data "aws_iam_policy_document" "task_execution_cloudwatch_access" {
  statement {
    effect = "Allow"
    actions = [
      "logs:PutRetentionPolicy",
      "logs:CreateLogGroup"
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${local.task_name}:*"]
  }
}

data "aws_iam_role" "task_execution_role" {
  count = var.ecs_task_execution_role_name != "" ? 1 : 0

  name = var.ecs_task_execution_role_name
}

locals {
  ecs_task_execution_role_arn  = var.ecs_task_execution_role_name != "" ? data.aws_iam_role.task_execution_role[0].arn : aws_iam_role.task_execution_role[0].arn
  ecs_task_execution_role_name = var.ecs_task_execution_role_name != "" ? data.aws_iam_role.task_execution_role[0].name : aws_iam_role.task_execution_role[0].name
}

resource "aws_iam_role" "task_execution_role" {
  count = var.ecs_task_execution_role_name == "" ? 1 : 0
  name               = "${local.task_name}-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role.json
}

resource "aws_iam_policy" "task_execution_logging_policy" {
  name   = "${local.task_name}-logging"
  policy = data.aws_iam_policy_document.task_execution_cloudwatch_access.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = var.ecs_task_execution_role_name == "" ? 1 : 0

  role       = local.ecs_task_execution_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_cloudwatch_access" {
  role       = local.ecs_task_execution_role_name
  policy_arn = aws_iam_policy.task_execution_logging_policy.arn
}

// Cloudwatch execution role
data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudwatch" {

  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = [aws_ecs_task_definition.this.arn]
  }
  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = concat([
      local.ecs_task_execution_role_arn
    ], var.task_role_arn != null ? [var.task_role_arn] : [])
  }
}

resource "aws_iam_role" "cloudwatch_role" {
  name               = "${local.task_name}-cloudwatch-execution"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json

}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}

resource "aws_iam_policy" "cloudwatch" {
  name   = "${local.task_name}-cloudwatch-execution"
  policy = data.aws_iam_policy_document.cloudwatch.json
}
