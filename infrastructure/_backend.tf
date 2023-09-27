terraform {
  backend "s3" {
    bucket = "epita-iac-talk-tfstate"
    key    = "terraform.tfstate"
    region = "eu-west-3"
  }
}
