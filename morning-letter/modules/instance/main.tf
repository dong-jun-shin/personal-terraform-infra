resource "aws_instance" "morning_letter_be_dev_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.keypair_name
  user_data              = var.user_data
  iam_instance_profile   = var.iam_instance_profile_name

  tags = merge(
    var.tags,
    {
      Name            = "${var.project_name}-${var.environment}-ec2"
      Role            = "api"
      DeploymentGroup = "${var.environment}-morning-letter-api" # CodeDeploy Group Target
    }
  )

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}
