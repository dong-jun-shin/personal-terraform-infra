# SSH Key Pair
resource "tls_private_key" "morning_letter_dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "morning_letter_dev_keypair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.morning_letter_dev_key.public_key_openssh
} 

resource "local_file" "user_local" {
  filename        = "${pathexpand("~")}/.ssh/${var.keypair_name}.pem"
  content         = tls_private_key.morning_letter_dev_key.private_key_pem
  file_permission = "0600"
}

# S3 bucket for infra file management
resource "aws_s3_bucket" "infra_files" {
  bucket = var.infra_files_bucket_name
  
  tags = merge(
    var.tags,
    {
      Name        = var.infra_files_bucket_name
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "infra_files_public_access_block" {
  bucket = aws_s3_bucket.infra_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "infra_files_versioning" {
  bucket = aws_s3_bucket.infra_files.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "infra_files_encryption" {
  bucket = aws_s3_bucket.infra_files.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Terraform State Storage
resource "aws_s3_bucket" "tfstate" {
  bucket = var.terraform_state_bucket_name

  tags = merge(
    {
      Name = var.terraform_state_bucket_name
      ManagedBy   = "terraform"
    },
    var.tags
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate_public_access_block" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_encryption" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Terraform State Lock Table
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = var.terraform_state_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    {
      Name = var.terraform_state_lock_table_name
    },
    var.tags
  )
} 
