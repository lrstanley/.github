locals {
  outline_bucket = "lrstanley-outline"
}

resource "cloudflare_r2_bucket" "outline" {
  account_id = var.cloudflare_account_id
  name       = local.outline_bucket
  location   = "enam"
}

resource "cloudflare_r2_bucket_cors" "outline" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.outline.name

  rules = [
    {
      id = "outline uploads"
      allowed = {
        methods = ["GET", "HEAD", "PUT"]
        origins = ["https://outline.ks.liam.sh"]
        headers = ["cache-control", "content-disposition", "content-type"]
      }
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
    },
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
