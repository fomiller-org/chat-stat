data "aws_iam_policy_document" "lambda_timestream_query" {
  statement {
    effect = "Allow"
    actions = [
      "timestream:*",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "lambda_timestream_query" {
  name   = "${title(var.namespace)}LambaTimestreamQueryPolicy"
  policy = data.aws_iam_policy_document.lambda_timestream_query.json
}
