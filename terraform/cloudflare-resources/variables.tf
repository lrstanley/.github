variable "cloudflare_api_token" {
  sensitive = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account identifier for R2 resources"
  type        = string
  sensitive   = true
}
