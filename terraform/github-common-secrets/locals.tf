locals {
  module_name = basename(abspath(path.module))

  secrets = {
    USER_PAT            = var.secret-user-pat
    SNYK_TOKEN          = var.secret-snyk-token
    CODECOV_TOKEN       = var.secret-codecov-token
    BOT_APP_ID          = var.secret-github-bot-app-id
    BOT_INSTALLATION_ID = var.secret-github-bot-installation-id
    BOT_PRIVATE_KEY     = var.secret-github-bot-private-key
  }
}

variable "github-token" {
  sensitive = true
}

variable "secret-user-pat" {
  sensitive = true
}
variable "secret-snyk-token" {
  sensitive = true
}

variable "secret-codecov-token" {
  sensitive = true
}

variable "secret-github-bot-app-id" {
  sensitive = true
}

variable "secret-github-bot-installation-id" {
  sensitive = true
}

variable "secret-github-bot-private-key" {
  sensitive = true
}
