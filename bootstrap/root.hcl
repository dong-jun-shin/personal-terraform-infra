locals {
  project_name                    = "infra-bootstrap"
  aws_region                      = "ap-northeast-2"
  infra_files_bucket_name         = "infra-files-2025"
  terraform_state_bucket_name     = "infra-terraform-state-2025"
  terraform_state_lock_table_name = "infra-terraform-state-lock-2025"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
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
    bucket         = local.terraform_state_bucket_name
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = local.terraform_state_lock_table_name
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
  infra_files_bucket_name         = local.infra_files_bucket_name
  terraform_state_bucket_name     = local.terraform_state_bucket_name
  terraform_state_lock_table_name = local.terraform_state_lock_table_name
}
