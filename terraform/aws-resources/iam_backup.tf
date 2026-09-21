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
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:Describe*",
      "s3:Get*",
      "s3:List*",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectRetention",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
    ]
  }
}

resource "aws_iam_user_policy" "backup_s3" {
  name   = "backup-s3"
  user   = aws_iam_user.backup.name
  policy = data.aws_iam_policy_document.backup_s3.json
}
