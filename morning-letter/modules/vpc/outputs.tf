output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_instance_id" {
  description = "ID of the NAT instance"
  value       = aws_instance.nat_instance.id
}

output "nat_instance_public_ip" {
  description = "Public IP of the NAT instance"
  value       = aws_instance.nat_instance.public_ip
}

# output "nat_gateway_id" {
#   description = "The ID of the NAT gateway"
#   value       = aws_nat_gateway.main.id
# }

output "app_security_group_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db.id
}

output "nat_instance_security_group_id" {
  description = "The ID of the NAT instance security group"
  value       = aws_security_group.nat_instance.id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}
