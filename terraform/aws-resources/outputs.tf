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
