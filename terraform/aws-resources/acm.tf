resource "aws_acm_certificate" "cdn" {
  domain_name = "${local.cdn_subdomain}.${local.cdn_domain}"
  #   subject_alternative_names = local.subject_alternative_names
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
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

resource "aws_acm_certificate_validation" "cdn_acm" {
  certificate_arn = aws_acm_certificate.cdn.arn

  validation_record_fqdns = [for r in cloudflare_record.cdn_acm : r.hostname]
}
