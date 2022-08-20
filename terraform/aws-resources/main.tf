terraform {
  cloud {
    organization = "lrstanley"

    workspaces {
      name = "aws-resources"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region     = local.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key

  default_tags {
    tags = {
      source     = "terraform"
      repository = "github.com/lrstanley/.github"
    }
  }
}
