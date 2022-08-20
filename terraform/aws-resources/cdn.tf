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
  acl    = "public-read"
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

data "aws_iam_policy_document" "cdn_s3" {
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
  policy = data.aws_iam_policy_document.cdn_s3.json
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "cdn" {
  bucket = aws_s3_bucket.cdn.id
  name   = "all-objects"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 180
  }
}

# resource "aws_cloudfront_origin_access_identity" "cdn" {
#   comment = "cdn"
# }

# module "cdn" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "2.9.3"

#   aliases = ["cdn.liam.sh"]

#   comment             = "cdn.liam.sh"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   wait_for_deployment = true

#   create_origin_access_identity = false
#   # origin_access_identities = {
#   #   cloudfront = "cloudfront"
#   # }

#   origin = {
#     cdn = {
#       domain_name = "lrstanley-cdn.s3.us-east-1.amazonaws.com"
#     }
#   }

#   default_cache_behavior = {
#     target_origin_id       = "cdn"
#     viewer_protocol_policy = "allow-all"

#     allowed_methods = ["GET", "HEAD", "OPTIONS"]
#     cached_methods  = ["GET", "HEAD"]
#     compress        = true
#     query_string    = false
#   }

#   viewer_certificate = {
#     acm_certificate_arn = "arn:aws:acm:us-east-1:135367859851:certificate/1032b155-22da-4ae0-9f69-e206f825458b"
#     ssl_support_method  = "sni-only"
#   }
# }
