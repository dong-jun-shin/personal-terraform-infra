include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "dev" {
  path = find_in_parent_folders("dev.hcl")
}

dependency "backend" {
  config_path = "../../../bootstrap/backend"
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  vpc_cidr             = "10.0.0.0/16"
  vpc_name             = "dev-vpc"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.4.0/24"]
  availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
  keypair_name         = dependency.backend.outputs.keypair_name
} 