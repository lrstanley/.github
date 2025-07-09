locals {
  region        = "us-east-1"
  cdn_subdomain = "cdn"
  cdn_domain    = "liam.sh"
  allowed_origins = [
    "https://liam.sh",
    "https://*.liam.sh",
  ]
}
