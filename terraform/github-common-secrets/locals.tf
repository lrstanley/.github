locals {
  module_name = basename(abspath(path.module))

  secrets = {
    USER_PAT   = var.secret-user-pat
    SNYK_TOKEN = var.secret-snyk-token
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
