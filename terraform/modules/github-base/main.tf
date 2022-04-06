terraform {
  required_providers {
    graphql = {
      source = "sullivtr/graphql"
    }
  }
}

variable "filters" {
  description = "repository filters to apply"
  type        = any
}
