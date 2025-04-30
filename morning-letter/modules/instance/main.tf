resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-be-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.keypair_name
  user_data     = var.user_data

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-${var.environment}-ec2-be"
        Role = "api"
      }
    )
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.project_name}-${var.environment}-asg-app-be"
  max_size                  = var.asg_app_config.max_size
  min_size                  = var.asg_app_config.min_size
  desired_capacity          = var.asg_app_config.desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [var.asg_app_config.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-ec2-be"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "api"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
