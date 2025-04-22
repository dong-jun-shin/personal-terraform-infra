locals {
  project_name        = "morning-letter"
  aws_region          = "ap-northeast-2"
  infra_files_bucket_name = "infra-morning-letter-files"
  terraform_state_bucket_name     = "infra-morning-letter-state"
  terraform_state_lock_table_name = "infra-morning-letter-lock"
}

# AWS 공급자 설정
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

# 원격 상태 저장소 설정
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

# Terraform 버전 설정
terraform {
  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute  = ["terraform", "fmt", "-recursive"]
  }
}

# 입력 변수 기본값 설정
inputs = {
  project_name   = local.project_name
  aws_region     = local.aws_region
  infra_files_bucket_name = local.infra_files_bucket_name
  terraform_state_bucket_name         = local.terraform_state_bucket_name
  terraform_state_lock_table_name = local.terraform_state_lock_table_name
}
