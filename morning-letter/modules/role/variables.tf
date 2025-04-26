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

variable "env_object_arn" {
  description = ".env file S3 Object ARN"
  type        = string
}

variable "github_pat_s3_object_arn" {
  description = "GitHub PAT S3 Object ARN"
  type        = string
}

variable "artifact_s3_object_arn" {
  description = "Artifact S3 Object ARN"
  type        = string
}