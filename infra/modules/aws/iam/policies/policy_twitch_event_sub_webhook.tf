data "aws_iam_policy_document" "lambda_twitch_event_sub_webhook" {
  statement {
    sid    = "LambdaTwitchEventSubDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams",
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.namespace}-${var.app_prefix}/stream/*"
    ]
  }

  statement {
    sid    = "LambdaDynamoDBTablePermissions"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.namespace}-${var.app_prefix}"
    ]
  }
}

resource "aws_iam_policy" "lambda_twitch_event_sub_webhook" {
  name   = "${title(var.namespace)}LambdaTwitchEventSubWebhookPolicy"
  policy = data.aws_iam_policy_document.lambda_twitch_event_sub_webhook.json
}
