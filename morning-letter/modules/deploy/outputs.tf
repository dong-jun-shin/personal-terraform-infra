output "codedeploy_app_name" {
  description = "CodeDeploy Application Name"
  value       = aws_codedeploy_app.this.name
}

output "codedeploy_deployment_group_name" {
  description = "CodeDeploy Deployment Group Name"
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "codedeploy_deployment_group_id" {
  description = "CodeDeploy Deployment Group ID"
  value       = aws_codedeploy_deployment_group.this.id
} 