### VPC -----------------------------------------------------------------------

locals {
  vpc_name        = "epita-iac-talk-vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.22.0/24", "10.0.33.0/24"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  vpc_tags = {
    CostCenter = "Network"
  }
}

### Bastion -------------------------------------------------------------------

module "bastion" {
  source = "https://github.com/padok-team/terraform-aws-bastion-ssm"

  instance_type       = "t4g.nano"
  vpc_zone_identifier = module.vpc.private_subnets_ids
}
