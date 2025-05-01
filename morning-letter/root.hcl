locals {
  project_name                    = "morning-letter"
  aws_region                      = "ap-northeast-2"
}

dependency "backend" {
  config_path = "../bootstrap/environments/prod/backend"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket         = dependency.backend.outputs.terraform_state_bucket_name
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = dependency.backend.outputs.terraform_state_lock_table_name
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute  = ["terraform", "fmt", "-recursive"]
  }
}

inputs = {
  project_name                    = local.project_name
  aws_region                      = local.aws_region
}
