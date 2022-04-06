terraform {
  backend "remote" {
    organization = "lrstanley"

    workspaces {
      name = "github-common-files"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
    graphql = {
      source  = "sullivtr/graphql"
      version = "2.5.1"
    }
  }

  required_version = ">= 1.0.0"
}

// Provider configurations.
provider "github" {
  token = var.github-token
}

provider "graphql" {
  url = "https://api.github.com/graphql"
  headers = {
    "Authorization" = "Bearer ${var.github-token}"
  }
}

// Variables.
variable "github-token" {
  type        = string
  description = "Github personal access token"
}

// Outputs.
output "github_user" {
  value = local.github_user
}

output "github_repositories" {
  value = local.repositories
}

output "configs" {
  value = local.ci_configs
}
