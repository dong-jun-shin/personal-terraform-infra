resource "aws_iam_role" "ec2_codedeploy_role" {
  name = "${var.project_name}-${var.environment}-ec2-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-codedeploy-role"
  }
}

resource "aws_iam_role_policy" "ec2_codedeploy_permissions" {
  name = "${var.project_name}-${var.environment}-ec2-codedeploy-permissions"
  role = aws_iam_role.ec2_codedeploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "codedeploy:GetDeploymentConfig",
            "codedeploy:BatchGetApplicationRevisions",
            "codedeploy:BatchGetDeployments",
            "codedeploy:ListDeploymentTargets",
            "codedeploy:GetDeploymentTarget",
            "codedeploy:GetDeploymentInstance",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "s3:GetObject"
        Resource = [
          var.env_object_arn,
          var.github_pat_s3_object_arn
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_codedeploy_role.name

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-profile"
  }
} 