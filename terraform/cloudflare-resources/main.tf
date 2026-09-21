terraform {
  cloud {
    organization = "lrstanley"

    workspaces {
      name = "cloudflare-resources"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.25.0"
    }
  }

  required_version = ">= 1.12.0"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
