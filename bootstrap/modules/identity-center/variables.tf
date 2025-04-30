variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "aws_region" {
  description = "The AWS region."
  type        = string
}

variable "instance_arn" {
  description = "The ARN of the IAM Identity Center instance."
  type        = string
}

variable "identity_store_id" {
  description = "The Identity Store ID associated with the Identity Center instance."
  type        = string
}

variable "groups" {
  description = "A map of groups to create."
  type = map(object({
    description = string
  }))
  default = {}
}
