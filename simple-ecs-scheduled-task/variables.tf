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

variable "stage" {
  type        = string
  description = "The stage of the environment to be created - for example, dev, staging, or production"
  default     = "development"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.stage)
    error_message = "Allowed values for stage are \"development\", \"staging\", or \"production\"."
  }
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
