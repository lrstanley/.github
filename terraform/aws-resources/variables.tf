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

variable "github-token" {
  description = "Github personal access token"
  type        = string
  sensitive   = true
}
