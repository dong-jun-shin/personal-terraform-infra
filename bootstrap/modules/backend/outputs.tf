output "infra_files_bucket_arn" {
  description = "The ARN of the S3 bucket for infra files"
  value       = aws_s3_bucket.infra_files.arn
}

output "keypair_name" {
  description = "The name of the SSH key pair"
  value       = aws_key_pair.morning_letter_keypair.key_name
}

output "user_file_path" {
  description = "The path to the user file"
  value       = local_file.user_local.filename
}

output "infra_files_bucket_name" {
  description = "The name of the S3 bucket for infra files"
  value       = aws_s3_bucket.infra_files.bucket
}

output "terraform_state_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}

output "terraform_state_lock_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.tfstate_lock.name
}
