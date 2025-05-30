terraform {
  cloud {
    organization = "lrstanley"

    workspaces {
      name = "github-common-secrets"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.12.0"
}

// Provider configurations.
provider "github" {
  token = var.github-token
}
