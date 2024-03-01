terraform {
  cloud {
    organization = "lrstanley"

    workspaces {
      name = "github-webhooks"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.7.0"
}

// Provider configurations.
provider "github" {
  token = var.github-token
}
