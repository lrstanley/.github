module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "4.0.0"

  aliases = ["${local.cdn_subdomain}.${local.cdn_domain}"]

  comment             = "${local.cdn_subdomain}.${local.cdn_domain}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = true

  create_origin_access_identity = true
  origin_access_identities = {
    cloudfront = "cloudfront"
  }

  origin = {
    cdn = {
      domain_name = aws_s3_bucket.cdn.bucket_regional_domain_name

      s3_origin_config = {
        origin_access_identity = "cloudfront"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "cdn"
    viewer_protocol_policy = "redirect-to-https" # allow-all

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true

    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
    response_headers_policy_id = "e61eb60c-9c35-4d20-a928-2b84e02af89c"
  }

  viewer_certificate = {
    acm_certificate_arn = aws_acm_certificate.cdn.arn
    ssl_support_method  = "sni-only"
  }
}
