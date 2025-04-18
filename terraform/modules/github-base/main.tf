terraform {
  required_providers {
    graphql = {
      source  = "sullivtr/graphql"
      version = "2.6.1"
    }
  }
}

provider "graphql" {
  url = "https://api.github.com/graphql"
  headers = {
    "Authorization" = "Bearer ${var.github_token}"
  }
}

variable "github_token" {
  description = "github token for authenticating to fetch information"
  type        = string
  sensitive   = true
}

variable "filters" {
  description = "repository filters to apply"
  type        = any
}

variable "exclude_names" {
  description = "repository names to exclude"
  type        = list(string)
  default     = []
}
