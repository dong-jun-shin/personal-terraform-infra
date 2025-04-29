resource "aws_codedeploy_app" "this" {
  name             = "${var.project_name}-${var.environment}-codedeploy-app"
  compute_platform = "Server"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-codedeploy-app"
      Role = "deployment-app"
    }
  )
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name              = aws_codedeploy_app.this.name
  deployment_group_name = "${var.project_name}-${var.environment}-codedeploy-deployment-group"
  service_role_arn      = var.codedeploy_service_role_arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = var.ec2_tag_key
      type  = "KEY_AND_VALUE"
      value = var.ec2_tag_value
    }
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-codedeploy-deployment-group"
      Role = "deployment-group"
    }
  )
} 