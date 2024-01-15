data "aws_iam_policy_document" "sfn_chat_stat_logger" {
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
  statement {
    effect = "Allow"
    actions = [
      "eks:*",
    ]
    resources = [
      "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.namespace}-cluster"
    ]
  }
}

resource "aws_iam_policy" "sfn_chat_stat_logger" {
  name   = "${title(var.namespace)}SfnChatStatLoggerPolicy"
  policy = data.aws_iam_policy_document.sfn_chat_stat_logger.json
}
