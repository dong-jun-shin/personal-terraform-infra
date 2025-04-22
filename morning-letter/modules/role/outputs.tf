output "codedeploy_service_role_arn" {
  description = "CodeDeploy Service Role ARN"
  value       = aws_iam_role.codedeploy_service_role.arn
}

output "ec2_codedeploy_role_arn" {
  description = "EC2 CodeDeploy Role ARN"
  value       = aws_iam_role.ec2_codedeploy_role.arn
}

output "ec2_instance_profile_name" {
  description = "EC2 Instance Profile Name"
  value       = aws_iam_instance_profile.ec2_profile.name
} 