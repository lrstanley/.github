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
      version = "5.91.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.0"
    }
  }

  required_version = ">= 1.7.0"
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

  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
