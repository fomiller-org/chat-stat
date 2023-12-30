data "aws_iam_policy_document" "lambda_event_sub" {
  statement {
    sid    = "LambdaEventSubDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.namespace}-${var.app_prefix}/stream/*"
    ]
  }
  statement {
    sid    = "LambdaEventListStreams"
    effect = "Allow"
    actions = [
      "lambda:ListStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_event_sub" {
  policy = data.aws_iam_policy_document.lambda_event_sub.json
  name   = "${title(var.namespace)}LambdaEventSubPolicy"
}

