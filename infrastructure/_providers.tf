terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


}

provider "aws" {
  region = "eu-west-3"

  default_tags {
    tags = {
      Project = "EPITA IaC Talk - 20231002"
    }
  }
}
