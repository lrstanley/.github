resource "aws_s3_bucket" "backup" {
  bucket = "lrstanley-backup"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "backup" {
  bucket = aws_s3_bucket.backup.id
  acl    = "private" # public-read

  depends_on = [aws_s3_bucket_ownership_controls.backup]
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id
  name   = "all-objects"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 180
  }
}
