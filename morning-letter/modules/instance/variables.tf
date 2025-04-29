variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod, etc.)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EC2 instance will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where instances will be deployed"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to apply to the application EC2 instance"
  type        = list(string)
}

variable "keypair_name" {
  description = "Key pair name to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "user_data" {
  description = "User data script to run when launching the EC2 instance"
  type        = string
  default     = ""
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile to associate with the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the EC2 instance"
  type        = map(string)
  default     = {}
}

variable "asg_app_config" {
  description = "Configuration for the Auto Scaling Group App"
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
    target_group_arn = string
  })
}
