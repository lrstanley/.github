locals {
  module_name = basename(abspath(path.module))
}

variable "github-token" {
  sensitive = true
}

variable "discord-webhook-url" {
  sensitive = true
}
