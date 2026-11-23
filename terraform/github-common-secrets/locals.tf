locals {
  module_name = basename(abspath(path.module))

  secrets = {
    USER_PAT          = var.secret-user-pat
    BOT_PRIVATE_KEY   = var.secret-github-bot-private-key
    RAILWAY_API_TOKEN = var.secret-railway-api-token
  }
}

variable "github-token" {
  sensitive = true
}

variable "secret-user-pat" {
  sensitive = true
}
variable "secret-github-bot-private-key" {
  sensitive = true
}

# Railway workspace token, for redeploying services from docker-release.yml.
variable "secret-railway-api-token" {
  sensitive = true
}
