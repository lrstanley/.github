resource "aws_iam_user" "outline" {
  name = "outline-docker-hq"
}

resource "aws_iam_access_key" "outline" {
  user = aws_iam_user.outline.name
}

data "aws_iam_policy_document" "outline_s3" {
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.outline.arn, "${aws_s3_bucket.outline.arn}/*"]

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
  name   = "outline-s3"
  user   = aws_iam_user.outline.name
  policy = data.aws_iam_policy_document.outline_s3.json
}
