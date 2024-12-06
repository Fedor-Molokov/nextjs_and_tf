provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "nextjs-static-assets-terraform"
    key            = "state.tfstate"
    region         = "eu-north-1"
    encrypt        = true
  }
}

