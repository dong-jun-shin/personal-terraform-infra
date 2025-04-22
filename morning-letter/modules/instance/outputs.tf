output "instance_id" {
  description = "Created EC2 instance ID"
  value       = aws_instance.morning_letter_be_dev_ec2.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.morning_letter_be_dev_ec2.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.morning_letter_be_dev_ec2.private_ip
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.morning_letter_be_dev_ec2.arn
}
