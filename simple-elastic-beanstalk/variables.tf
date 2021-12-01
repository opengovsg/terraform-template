variable "allowed_account_id" {
  description = "Avoid nuking the wrong AWS account"
  type        = string
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

variable "aws_azs" {
  type        = list(string)
  description = "List of Availability Zones to deploy resources into"
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "eb_solution_stack_name" {
  type        = string
  description = "Elastic Beanstalk solution stack name"
  default     = "64bit Amazon Linux 2 v3.4.10 running Docker"
}
variable "app_name" {
  type        = string
  description = "The name of the application"
}

variable "db_name" {
  type        = string
  description = "The name of the database schema name to create"
  validation {
    condition     = can(regex("[a-zA-Z][a-zA-Z0-9]*", var.db_name))
    error_message = "The db_name variable must adhere to the following regex: \"[a-zA-Z][a-zA-Z0-9]*\"."
  }
}
variable "db_root_user" {
  type        = string
  description = "Database root username (do not user \"user\")!"
  default     = "postgres"
}

variable "db_root_password" {
  type        = string
  description = "Database root password"
}