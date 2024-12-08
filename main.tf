terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "nextjs-static-assets-terraform"
    key            = "state.tfstate"
    region         = "eu-north-1"
    encrypt        = true
  }
}

locals {
  default_tags = {
    Project     = "terraform-aws-opennext"
    Environment = "example"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.default_tags
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "opennext" {
  source       = "./modules/opennext"

  prefix              = "opennext-${random_id.suffix.hex}"
  default_tags        = local.default_tags
  opennext_build_path = "./out"
  hosted_zone_id      = ""

  cloudfront = {
    aliases             = []
    acm_certificate_arn = ""
    assets_paths        = []
  }
  
}
