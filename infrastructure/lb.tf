locals {
  hostname = "epita-demo.${data.aws_route53_zone.zone.name}"
}

# Application Load Balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "epita-iac-talk-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.alb.id]

  # Instance Target group (referenced by Auto-Scaling Group)
  target_groups = [
    {
      name_prefix          = "fibo-"
      backend_protocol     = "HTTP"
      backend_port         = 8000
      target_type          = "instance"
      deregistration_delay = 5
      health_check = {
        enabled             = true
        path                = "/healthz"
        interval            = 5
        healthy_threshold   = 3
        unhealthy_threshold = 2
        timeout             = 4
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  # Redirect HTTP traffic to HTTPS
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]
}

resource "aws_security_group" "alb" {
  name   = "epita-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "epita-alb-sg"
  }
}

data "aws_route53_zone" "zone" {
  name = "padok.school"
}

# SSL certificate for Application Load Balancer
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = local.hostname
  zone_id     = data.aws_route53_zone.zone.zone_id

  tags = {
    Name = local.hostname
  }
}

# DNS record for LB
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.hostname
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
