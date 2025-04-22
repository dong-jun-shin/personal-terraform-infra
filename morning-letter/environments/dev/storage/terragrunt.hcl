include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "dev" {
  path = find_in_parent_folders("dev.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "../../../modules/storage"

  extra_arguments "secrets" {
    commands = ["apply", "plan", "destroy"]
    arguments = ["-var-file=${get_terragrunt_dir()}/secrets.tfvars"]
  }
}

inputs = {
  vpc_id              = dependency.vpc.outputs.vpc_id
  subnet_ids          = dependency.vpc.outputs.private_subnet_ids
  security_group_ids  = [dependency.vpc.outputs.db_security_group_id]
  
  db_name             = "morning_letter"
  db_username         = "morning_letter_admin"
  db_password         = "WILL_BE_SET_FROM_TFVARS"
  
  db_instance_class   = "db.t4g.micro"
  db_allocated_storage = 20
  db_engine_version   = "17.4"
  db_parameter_group_name = "default.postgres17"
  
  db_skip_final_snapshot = true
  db_backup_retention_period = 7
  db_multi_az = false
  
  tags = {
    Service = "morning-letter-database"
    Role    = "database"
  }
} 