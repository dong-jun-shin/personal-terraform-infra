variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment Environment (dev, prod, etc.)"
  type        = string
}

variable "codedeploy_service_role_arn" {
  description = "CodeDeploy Service Role ARN"
  type        = string
}

variable "ec2_tag_key" {
  description = "CodeDeploy Deployment Group Target EC2 Instance Tag Key"
  type        = string
  default     = "DeploymentGroup"
}

variable "ec2_tag_value" {
  description = "CodeDeploy Deployment Group Target EC2 Instance Tag Value"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the CodeDeploy resources"
  type        = map(string)
  default     = {}
}
