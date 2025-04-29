output "codedeploy_app_name" {
  description = "CodeDeploy Application Name"
  value       = aws_codedeploy_app.this.name
}

output "codedeploy_init_deployment_group_name" {
  description = "initial deployment group name"
  value       = try(aws_codedeploy_deployment_group.init[0].deployment_group_name, null)
}

output "codedeploy_init_deployment_group_id" {
  description = "initial deployment group id"
  value       = try(aws_codedeploy_deployment_group.init[0].id, null)
}

output "codedeploy_blue_green_deployment_group_name" {
  description = "blue/green deployment group name"
  value       = try(aws_codedeploy_deployment_group.blue_green[0].deployment_group_name, null)
}

output "codedeploy_blue_green_deployment_group_id" {
  description = "blue/green deployment group id"
  value       = try(aws_codedeploy_deployment_group.blue_green[0].id, null)
}