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
    allowed_origins = ["https://outline.docker.hq.liam.sh", "https://outline.ks.liam.sh"]
    expose_headers  = []
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "outline" {
  bucket = aws_s3_bucket.outline.id
  name   = "all-objects"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 180
  }
}
