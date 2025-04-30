# Group
resource "aws_identitystore_group" "this" {
  for_each = var.groups

  identity_store_id = var.identity_store_id
  display_name      = each.key
  description       = each.value.description
} 

# Permission Set
resource "aws_ssoadmin_permission_set" "system_administrator" {
  instance_arn     = var.instance_arn
  name             = "SystemAdministrator"
  description      = "System Administrator"
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "system_administrator_policy" {
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.system_administrator.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
} 

resource "aws_ssoadmin_permission_set_inline_policy" "system_administrator_inline_policy" {
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.system_administrator.arn
  inline_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Statement1",
        Effect = "Allow",
        Action = [
          "iam:CreateServiceLinkedRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:TagRole",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:TagInstanceProfile",
          "dynamodb:DescribeTable",
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
          "rds:CreateDBSubnetGroup",
          "rds:DeleteDBSubnetGroup",
          "rds:AddTagsToResource",
          "rds:CreateDBInstance",
          "rds:ModifyDBInstance",
          "rds:DeleteDBInstance",
          "rds:CreateDBInstanceReadReplica",
          "rds:CreateDBParameterGroup",
          "rds:ModifyDBParameterGroup",
          "rds:DeleteDBParameterGroup",
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "ec2:CreateNetworkAcl",
          "ec2:CreateNetworkAclEntry"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
} 

# Permission Set
resource "aws_ssoadmin_permission_set" "developer" {
  instance_arn     = var.instance_arn
  name             = "Developer"
  description      = "Developer"
  session_duration = "PT1H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "developer_inline_policy" {
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  inline_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Statement1",
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::infra-files-2025/*"
        ]
      }
    ]
  })
} 