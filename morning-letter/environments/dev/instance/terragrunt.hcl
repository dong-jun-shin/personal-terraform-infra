include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "dev" {
  path = find_in_parent_folders("dev.hcl")
}

dependency "backend" {
  config_path = "../../../bootstrap/backend"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "role" {
  config_path = "../role"
}

terraform {
  source = "../../../modules/instance"
}

inputs = {
  vpc_id                      = dependency.vpc.outputs.vpc_id
  public_subnet_ids           = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids          = dependency.vpc.outputs.private_subnet_ids
  security_group_ids          = [dependency.vpc.outputs.app_security_group_id] 
  iam_instance_profile_name = dependency.role.outputs.ec2_instance_profile_name
  keypair_name              = dependency.backend.outputs.keypair_name

  # EC2 instance settings
  instance_type = "t3.micro"
  ami_id        = "ami-0a463f27534bdf246" # Amazon Linux 2023
  user_data = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y ruby wget

      # Install Agent
      cd /home/ec2-user
      wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
      chmod +x ./install
      ./install auto --region ap-northeast-2 
      systemctl start codedeploy-agent
      systemctl enable codedeploy-agent

      # Install Docker
      amazon-linux-extras install docker -y
      systemctl start docker
      systemctl enable docker
      usermod -a -G docker ec2-user

      # Create application directory
      mkdir -p /opt/morning-letter/logs
      chown -R ec2-user:ec2-user /opt/morning-letter
      
      # Set permissions for CodeDeploy Agent log directory
      mkdir -p /var/log/aws/codedeploy-agent
      chown -R root:root /var/log/aws/codedeploy-agent
      
      # Check CodeDeploy Agent status
      systemctl status codedeploy-agent
      
      # Set environment variables
      echo "export APP_HOME=/opt/morning-letter" >> /home/ec2-user/.bashrc
      echo "export NODE_ENV=development" >> /home/ec2-user/.bashrc
      source /home/ec2-user/.bashrc
      EOF
}  