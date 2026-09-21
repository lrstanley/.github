locals {
  cdn_bucket = "lrstanley-cdn"
  cdn_domain = "cdn-new.liam.sh"
}

data "cloudflare_zones" "cdn_domain" {
  name = "liam.sh"
}

resource "cloudflare_r2_bucket" "cdn" {
  account_id = var.cloudflare_account_id
  name       = local.cdn_bucket
  location   = "enam"
}

resource "cloudflare_r2_bucket_cors" "cdn" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.cdn.name

  rules = [
    {
      id = "public reads"
      allowed = {
        methods = ["GET", "HEAD"]
        origins = ["*"]
      }
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
    },
  ]
}

resource "cloudflare_r2_custom_domain" "cdn" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.cdn.name
  domain      = local.cdn_domain
  enabled     = true
  zone_id     = data.cloudflare_zones.cdn_domain.result[0].id
}
