provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "state-bucket-sobes"
    key            = "state.tfstate"
    region         = "eu-north-1"
    encrypt        = true
  }
}

