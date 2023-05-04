output "outline_bucket" {
  value = aws_s3_bucket.outline.id
}

output "outline_access_key" {
  value     = aws_iam_access_key.outline.id
  sensitive = true
}

output "outline_secret_key" {
  value     = aws_iam_access_key.outline.secret
  sensitive = true
}

output "cdn_bucket" {
  value = aws_s3_bucket.cdn.id
}

output "cdn_access_key" {
  value     = aws_iam_access_key.cdn.id
  sensitive = true
}

output "cdn_secret_key" {
  value     = aws_iam_access_key.cdn.secret
  sensitive = true
}

output "backup_bucket" {
  value = aws_s3_bucket.backup.id
}

output "backup_access_key" {
  value     = aws_iam_access_key.backup.id
  sensitive = true
}

output "backup_secret_key" {
  value     = aws_iam_access_key.backup.secret
  sensitive = true
}
