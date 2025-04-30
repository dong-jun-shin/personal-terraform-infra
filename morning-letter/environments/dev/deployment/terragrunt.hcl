include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "dev" {
  path = find_in_parent_folders("dev.hcl")
}

dependency "role" {
  config_path = "../role"
}

dependency "alb" {
  config_path = "../alb"
}

dependency "instance" {
  config_path = "../instance"
}

terraform {
  source = "../../../modules/deployment"
}

inputs = {
  codedeploy_service_role_arn = dependency.role.outputs.codedeploy_service_role_arn
  asg_app_name = dependency.instance.outputs.asg_app_name           # When deleting, use ASG created by CodeDeploy
  init_asg_app = false

  lb_listener_arns = [dependency.alb.outputs.http_listener_arn]
  lb_target_group_name = dependency.alb.outputs.target_group_name
} 
