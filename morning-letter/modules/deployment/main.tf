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

resource "aws_codedeploy_deployment_group" "init" {
  count                 = var.init_asg_app ? 1 : 0
  app_name              = aws_codedeploy_app.this.name
  deployment_group_name = "${var.project_name}-${var.environment}-codedeploy-deployment-group-init"
  service_role_arn      = var.codedeploy_service_role_arn

  autoscaling_groups = [var.asg_app_name]
  
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-codedeploy-deployment-group-init"
      Role = "deployment-group"
    }
  )

  lifecycle {
    ignore_changes = [autoscaling_groups]
  }
}
resource "aws_codedeploy_deployment_group" "blue_green" {
  count                 = var.init_asg_app ? 0 : 1
  app_name              = aws_codedeploy_app.this.name
  deployment_group_name = "${var.project_name}-${var.environment}-codedeploy-deployment-group-blue-green"
  service_role_arn      = var.codedeploy_service_role_arn

  autoscaling_groups = [var.asg_app_name]

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = var.lb_target_group_name
    }
  }
  
  blue_green_deployment_config {
    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
    
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-codedeploy-deployment-group"
      Role = "deployment-group"
    }
  )

  lifecycle {
    ignore_changes = [autoscaling_groups]
  }
} 