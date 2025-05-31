resource "aws_iam_user" "mcp_kubesearch" {
  name = "mcp-kubesearch"
}

resource "aws_iam_access_key" "mcp_kubesearch" {
  user = aws_iam_user.mcp_kubesearch.name
}

data "aws_iam_policy_document" "mcp_kubesearch_user" {
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.cdn.arn, "${aws_s3_bucket.cdn.arn}/mcp-kubesearch/*"]

    actions = [
      "s3:PutObject",
    ]
  }
}

resource "aws_iam_user_policy" "mcp_kubesearch_s3" {
  name   = "mcp_kubesearch-s3"
  user   = aws_iam_user.mcp_kubesearch.name
  policy = data.aws_iam_policy_document.mcp_kubesearch_user.json
}

resource "github_actions_secret" "mcp_kubesearch_access_key" {
  repository      = "mcp-kubesearch"
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.mcp_kubesearch.id
}

resource "github_actions_secret" "mcp_kubesearch_secret_key" {
  repository      = "mcp-kubesearch"
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.mcp_kubesearch.secret
}
