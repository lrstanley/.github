data "cloudflare_zones" "cdn_domain" {
  filter {
    name = local.cdn_domain
  }
}

resource "cloudflare_record" "cdn_acm" {
  for_each = {
    for dvo in aws_acm_certificate.cdn.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = lookup(data.cloudflare_zones.cdn_domain.zones[0], "id")

  name            = each.value.name
  type            = each.value.type
  value           = each.value.record
  proxied         = false
  allow_overwrite = true
}
