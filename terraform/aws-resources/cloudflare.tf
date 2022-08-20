data "cloudflare_zones" "cdn_domain" {
  filter {
    name = local.cdn_domain
  }
}
