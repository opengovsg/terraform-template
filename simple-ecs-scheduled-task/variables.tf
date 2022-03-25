variable "allowed_account_id" {
  type        = string
  description = "Avoid nuking the wrong AWS account"
}

variable "aws_profile" {
  type        = string
  description = "The profile for API operations. If not set, the default profile created with aws configure will be used."
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources to"
  default     = "ap-southeast-1"
}

variable "app_name" {
  type        = string
  description = "The name of the application"
}

variable "capacity_providers" {
  type        = list(string)
  description = "The capacity providers that can be used by the ECS cluster"
  default     = ["FARGATE", "FARGATE_SPOT"]

  validation {
    // See https://discuss.hashicorp.com/t/validate-list-object-variables/18291/2
    condition     = alltrue([
      for provider in var.capacity_providers : contains(["FARGATE", "FARGATE_SPOT"], provider)
    ])
    error_message = "Capacity providers must be one of \"FARGATE\", \"FARGATE_SPOT\", or both."
  }
}

variable "image" {
  type        = string
  description = "The image that is used to start the container by the ECS task definition. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_image for more information."
  default     = "public.ecr.aws/cloudwatch-agent/cloudwatch-agent:latest"
}

variable "scheduled_task_description" {
  type        = string
  description = "Description for the ECS scheduled task"
}

variable "scheduled_task_schedule_expression" {
  type        = string
  description = "An expression that determines the schedule that the task will run on. For example, cron(0 20 * * ? *) or rate(5 minutes)"
  default     = "rate(5 minutes)"
}

variable "scheduled_task_target_security_groups" {
  type        = list(string)
  description = "A list of security groups that the container executing your task should be a part of"
  default     = []
}

variable "scheduled_task_target_subnets" {
  type        = list(string)
  description = "A list of subnets that the container executing your task should be a part of"
}

variable "ecs_task_execution_role_name" {
  type        = string
  description = "The IAM role that will be used for ECS task execution"
  default     = ""
}

variable "task_role_arn" {
  type        = string
  description = "The arn of the task role that will be used for ECS task execution"
}