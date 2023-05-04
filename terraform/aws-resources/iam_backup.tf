resource "aws_iam_user" "backup" {
  name = "backup"
}

resource "aws_iam_access_key" "backup" {
  user = aws_iam_user.backup.name
}

data "aws_iam_policy_document" "backup_s3" {
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.backup.arn, "${aws_s3_bucket.backup.arn}/*"]

    actions = [
      "s3:GetObjectAcl",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectAcl",
    ]
  }
}

resource "aws_iam_user_policy" "backup_s3" {
  name   = "backup-s3"
  user   = aws_iam_user.backup.name
  policy = data.aws_iam_policy_document.backup_s3.json
}
