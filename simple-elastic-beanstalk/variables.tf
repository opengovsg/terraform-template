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

variable "db_root_user" {
  type        = string
  description = "Database root username (do not user \"user\")!"
  default     = "postgres"
}

variable "db_root_password" {
  type        = string
  description = "Database root password"
}