resource "aws_acm_certificate" "cdn" {
  domain_name = "${local.cdn_subdomain}.${local.cdn_domain}"
  #   subject_alternative_names = local.subject_alternative_names
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cdn_acm" {
  certificate_arn = aws_acm_certificate.cdn.arn

  validation_record_fqdns = [for r in cloudflare_record.cdn_acm : r.hostname]
}
