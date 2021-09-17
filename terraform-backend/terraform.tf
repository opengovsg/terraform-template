provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "starter-kit-terraform-experiments"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "starter-kit-terraform-experiments-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
