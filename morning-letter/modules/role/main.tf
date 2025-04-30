# Github actions oidc provider for cd deploy
data "tls_certificate" "github_oidc_thumbprint" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_oidc_thumbprint.certificates[0].sha1_fingerprint]

  tags = {
    Name = "github-actions-oidc-provider"
  }
}

resource "aws_iam_role" "github_actions_cd_deploy" {
  name = "github-actions-cd-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_oidc_sub
          }
        }
      }
    ]
  })

  tags = {
    Name = "github-actions-cd-deploy"
  }
} 

# Codedeploy service role
resource "aws_iam_role" "codedeploy_service_role" {
  name = "${var.project_name}-${var.environment}-codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-codedeploy-service-role"
  }
}

resource "aws_iam_role_policy" "codedeploy_service_permissions" {
  name       = "${var.project_name}-${var.environment}-codedeploy-service-permissions"
  role       = aws_iam_role.codedeploy_service_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy_service_role.name
}

# Codedeploy ec2 role
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
          var.github_pat_s3_object_arn,
          var.artifact_s3_object_arn
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
