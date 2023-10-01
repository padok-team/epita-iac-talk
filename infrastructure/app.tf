locals {
  user_data = <<EOF
#!/bin/bash
cd /home/ubuntu
wget https://github.com/padok-team/epita-iac-talk/releases/download/v1.0/fibo-server_linux_amd64
chmod +x fibo-server_linux_amd64
sudo mv fibo-server_linux_amd64 /usr/bin/fibo-server
wget https://raw.githubusercontent.com/padok-team/epita-iac-talk/main/webapp.service
sudo mv webapp.service /etc/systemd/system/webapp.service
sudo systemctl daemon-reload
sudo systemctl enable webapp.service
sudo systemctl start webapp.service
EOF
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  # Canonical
  owners = ["099720109477"]
}

resource "aws_security_group" "app" {
  name   = "epita-demo-app"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "epita-demo-app"
  }
}

# Auto-Scaling Group for Frontend instance
module "back_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.0"

  name = "epita-demo-app"

  vpc_zone_identifier = module.vpc.private_subnets
  desired_capacity    = 1
  min_size            = 1
  max_size            = 5

  image_id          = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  enable_monitoring = true

  target_group_arns = module.alb.target_group_arns

  user_data                = base64encode(local.user_data)
  security_groups          = [aws_security_group.app.id]
  iam_instance_profile_arn = aws_iam_instance_profile.app.arn

  # scaling_policies = {
  #   avg-cpu-policy-greater-than-50 = {
  #     policy_type               = "TargetTrackingScaling"
  #     estimated_instance_warmup = 60
  #     target_tracking_configuration = {
  #       predefined_metric_specification = {
  #         predefined_metric_type = "ASGAverageCPUUtilization"
  #       }
  #       target_value = 50.0
  #     }
  #   }
  # }
}
