include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "dev" {
  path = find_in_parent_folders("dev.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "../../../modules/alb"
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  public_subnet_ids  = dependency.vpc.outputs.public_subnet_ids
  security_group_ids = [dependency.vpc.outputs.alb_security_group_id]

  target_group_port = 80
  health_check_path = "/health"
  internal            = false
} 