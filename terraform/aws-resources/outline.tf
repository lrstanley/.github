resource "aws_s3_bucket" "outline" {
  bucket = "lrstanley-outline"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "outline" {
  bucket = aws_s3_bucket.outline.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "outline" {
  bucket = aws_s3_bucket.outline.id
  acl    = "private" # public-read
}

resource "aws_s3_bucket_public_access_block" "outline" {
  bucket = aws_s3_bucket.outline.id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "outline" {
  bucket = aws_s3_bucket.outline.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://outline.docker.hq.liam.sh"]
    expose_headers  = []
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_iam_user" "outline" {
  name = "outline-docker-hq"
}

resource "aws_iam_access_key" "outline" {
  user = aws_iam_user.outline.name
}

data "aws_iam_policy_document" "outline_s3" {
  statement {
    sid       = "outline-s3"
    effect    = "Allow"
    resources = [aws_s3_bucket.outline.arn]

    actions = [
      "s3:GetObjectAcl",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectAcl",
    ]
  }
}

resource "aws_iam_user_policy" "outline_s3" {
  name   = "test"
  user   = aws_iam_user.outline.name
  policy = data.aws_iam_policy_document.outline_s3.json
}

# resource "aws_s3_bucket_lifecycle_configuration" "outline" {
#   bucket = aws_s3_bucket.outline.id

#   rule {
#     id = "transitions"
#     status = "Enabled"
#     abort_incomplete_multipart_upload {
#         days_after_initiation = 7
#     }

#     # ... other transition/expiration actions ...
#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }

#     transition {
#       days          = 90
#       storage_class = "GLACIER"
#     }
#   }
# }
