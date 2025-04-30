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

variable "asg_app_name" {
  description = "ASG App Name"
  type = string
}

variable "init_asg_app" {
  description = "initial ASG App"
  type        = bool
}

variable "lb_listener_arns" {
  description = "List of Load Balancer listener ARNs to register with the deployment group"
  type        = list(string)
}

variable "lb_target_group_name" {
  description = "Object containing the name of the target group"
  type = string
}

variable "tags" {
  description = "Tags to apply to the CodeDeploy resources"
  type        = map(string)
  default     = {}
}
