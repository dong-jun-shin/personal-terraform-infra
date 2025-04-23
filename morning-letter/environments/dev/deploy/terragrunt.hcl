include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "dev" {
  path = find_in_parent_folders("dev.hcl")
}

dependency "role" {
  config_path = "../role"
}

terraform {
  source = "../../../modules/deploy"
}

inputs = {
  codedeploy_service_role_arn = dependency.role.outputs.codedeploy_service_role_arn
  
  ec2_tag_key   = "DeploymentGroup"
  ec2_tag_value = "${include.dev.outputs.environment}-morning-letter-api"
} 