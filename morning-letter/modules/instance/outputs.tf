output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "The latest version number of the launch template"
  value       = aws_launch_template.this.latest_version
}

output "asg_app_name" {
  description = "The name of the Auto Scaling Group App"
  value       = aws_autoscaling_group.this.name
}

output "asg_app_arn" {
  description = "The ARN of the Auto Scaling Group App"
  value       = aws_autoscaling_group.this.arn
}
