resource "aws_s3_bucket" "cdn" {
  bucket = "lrstanley-cdn"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cdn" {
  bucket = aws_s3_bucket.cdn.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "cdn" {
  bucket = aws_s3_bucket.cdn.id
  acl    = "private"
}

data "aws_iam_policy_document" "cdn_s3" {
  statement {
    actions   = ["s3:GetObject"]
    resources = [aws_s3_bucket.cdn.arn, "${aws_s3_bucket.cdn.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = module.cdn.cloudfront_origin_access_identity_iam_arns
    }
  }

  statement {
    actions = [
      "s3:GetObjectAcl",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectAcl",
    ]
    resources = [aws_s3_bucket.cdn.arn, "${aws_s3_bucket.cdn.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = aws_iam_user.cdn.arn
    }
  }
}

resource "aws_s3_bucket_policy" "cdn" {
  bucket = aws_s3_bucket.cdn.id
  policy = data.aws_iam_policy_document.cdn_s3.json
}

resource "aws_s3_bucket_public_access_block" "cdn" {
  bucket = aws_s3_bucket.cdn.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "cdn" {
  name = "cdn"
}

resource "aws_iam_access_key" "cdn" {
  user = aws_iam_user.cdn.name
}

data "aws_iam_policy_document" "cdn_user" {
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.cdn.arn, "${aws_s3_bucket.cdn.arn}/*"]

    actions = [
      "s3:GetObjectAcl",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectAcl",
    ]
  }
}

resource "aws_iam_user_policy" "cdn_s3" {
  name   = "cdn-s3"
  user   = aws_iam_user.cdn.name
  policy = data.aws_iam_policy_document.cdn_user.json
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "cdn" {
  bucket = aws_s3_bucket.cdn.id
  name   = "all-objects"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 180
  }
}

module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.3"

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
