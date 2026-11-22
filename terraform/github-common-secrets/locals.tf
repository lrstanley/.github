locals {
  module_name = basename(abspath(path.module))

  secrets = {
    USER_PAT        = var.secret-user-pat
    BOT_PRIVATE_KEY = var.secret-github-bot-private-key
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
