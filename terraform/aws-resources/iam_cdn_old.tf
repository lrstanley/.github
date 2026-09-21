resource "aws_iam_user" "cdn" {
  name = "cdn"
}

resource "aws_iam_access_key" "cdn" {
  user = aws_iam_user.cdn.name
}

data "aws_iam_policy_document" "cdn_user" {
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.cdn.arn, "${aws_s3_bucket.cdn.arn}/*"]

    actions = [
      "s3:GetObjectAcl",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectAcl",
      "s3:List*",
    ]
  }
}

resource "aws_iam_user_policy" "cdn_s3" {
  name   = "cdn-s3"
  user   = aws_iam_user.cdn.name
  policy = data.aws_iam_policy_document.cdn_user.json
}
