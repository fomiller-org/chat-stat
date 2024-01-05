data "aws_iam_policy_document" "lambda_twitch_event_sub" {
  statement {
    sid    = "LambdaTwitchEventSubDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.namespace}-${var.app_prefix}/stream/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_twitch_event_sub" {
  name   = "${title(var.namespace)}LambdaTwitchEventSubPolicy"
  policy = data.aws_iam_policy_document.lambda_twitch_event_sub.json
}
