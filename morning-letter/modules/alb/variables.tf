variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy the ALB"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, stg, prd)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the ALB"
  type        = list(string)
}

variable "target_group_port" {
  description = "The port on which targets receive traffic"
  type        = number
}

variable "health_check_path" {
  description = "The destination for the health check request"
  type        = string
  default     = "/health"
}

variable "internal" {
  description = "Boolean flag to determine if the ALB is internal"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
