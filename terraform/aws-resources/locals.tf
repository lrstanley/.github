locals {
  region        = "us-east-1"
  cdn_subdomain = "cdn"
  cdn_domain    = "liam.sh"
}

variable "aws_account_id" {
  sensitive = true
}

variable "aws_access_key_id" {
  sensitive = true
}

variable "aws_secret_access_key" {
  sensitive = true
}

variable "cloudflare_api_token" {
  sensitive = true
}
