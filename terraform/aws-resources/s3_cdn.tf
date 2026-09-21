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
      identifiers = [aws_iam_user.cdn.arn]
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

resource "aws_s3_bucket_intelligent_tiering_configuration" "cdn" {
  bucket = aws_s3_bucket.cdn.id
  name   = "all-objects"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 180
  }
}
