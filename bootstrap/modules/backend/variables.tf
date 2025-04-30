variable "project_name" {
  description = "The name of the project name"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "infra_files_bucket_name" {
  description = "The name of the S3 bucket for infra files"
  type        = string
}

variable "terraform_state_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
}

variable "terraform_state_lock_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  type        = string
}

variable "keypair_name" {
  description = "Key pair name to use for the EC2 instance"
  type        = string
}
