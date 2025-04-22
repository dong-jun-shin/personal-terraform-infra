resource "aws_db_instance" "morning_letter_dev_db" {
  identifier           = "${var.project_name}-${var.environment}-db"
  engine              = "postgres"
  engine_version      = var.db_engine_version
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  storage_type        = "gp3"
  
  port                   = 5432
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.morning_letter_dev_db_subnet_group.name

  parameter_group_name    = aws_db_parameter_group.postgres_params.name
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  
  multi_az               = var.db_multi_az
  publicly_accessible    = false
  deletion_protection    = false
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-db"
    }
  )
}

resource "aws_db_subnet_group" "morning_letter_dev_db_subnet_group" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
} 

resource "aws_db_parameter_group" "postgres_params" {
  name   = "${var.project_name}-${var.environment}-pg"
  family = "postgres17"
  
  parameter {
    name  = "timezone"
    value = "UTC"
  }
}
