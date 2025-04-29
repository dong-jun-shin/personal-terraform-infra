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

dependency "alb" {
  config_path = "../alb"
}

terraform {
  source = "../../../modules/instance"
}

inputs = {
  vpc_id                      = dependency.vpc.outputs.vpc_id
  private_subnet_ids          = dependency.vpc.outputs.private_subnet_ids
  security_group_ids          = [dependency.vpc.outputs.app_security_group_id]
  iam_instance_profile_name   = dependency.role.outputs.ec2_instance_profile_name
  keypair_name                = dependency.backend.outputs.keypair_name
  
  asg_app_config = {
    min_size         = 0
    max_size         = 2
    desired_capacity = 1
    target_group_arn = dependency.alb.outputs.target_group_arn
  }

  # Instance
  instance_type               = "t3.micro"
  ami_id                      = "ami-0a463f27534bdf246" # Amazon Linux 2023
  user_data                   = base64encode(<<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - ruby
      - wget
      - docker

    runcmd:
      # dnf update -y
      # dnf install -y ruby wget

      # Install Agent
      - |
        cd /home/ec2-user
        wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
        chmod +x ./install
        ./install auto
        systemctl start codedeploy-agent
        systemctl enable codedeploy-agent

      # # Install Docker
      # dnf install docker -y
      - |
        systemctl start docker
        systemctl enable docker
        usermod -a -G docker ec2-user

      # Create application directory
      - |
        mkdir -p /opt/morning-letter/logs
        chown -R ec2-user:ec2-user /opt/morning-letter

      # Check CodeDeploy Agent status
      - |
        systemctl status codedeploy-agent

      # Set environment variables
      - |
        echo "export APP_HOME=/opt/morning-letter" >> /home/ec2-user/.bashrc
        echo "export NODE_ENV=development" >> /home/ec2-user/.bashrc
        source /home/ec2-user/.bashrc
      EOF
  )
}  