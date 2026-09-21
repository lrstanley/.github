output "r2_outline_bucket" {
  value = cloudflare_r2_bucket.outline.name
}

output "r2_cdn_bucket" {
  value = cloudflare_r2_bucket.cdn.name
}

output "r2_cdn_domain" {
  value = cloudflare_r2_custom_domain.cdn.domain
}

output "r2_s3_endpoint" {
  value     = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  sensitive = true
}
