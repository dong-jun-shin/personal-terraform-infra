output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.morning_letter_dev_db.endpoint
}

output "db_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.morning_letter_dev_db.port
}

output "db_name" {
  description = "Database name of the RDS instance"
  value       = aws_db_instance.morning_letter_dev_db.db_name
}

output "db_username" {
  description = "Master username of the RDS instance"
  value       = aws_db_instance.morning_letter_dev_db.username
}

output "db_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.morning_letter_dev_db.arn
}

output "db_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.morning_letter_dev_db_subnet_group.name
}
