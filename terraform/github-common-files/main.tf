terraform {
  cloud {
    organization = "lrstanley"

    workspaces {
      name = "github-common-files"
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

// Variables.
variable "github-token" {
  description = "Github personal access token"
  type        = string
  sensitive   = true
}

// Outputs.
output "github_repositories" {
  value = module.base.repositories
}

output "configs" {
  value = module.base.ci_configs
}
