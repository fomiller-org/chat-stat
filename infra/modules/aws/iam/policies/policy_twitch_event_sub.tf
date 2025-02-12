data "aws_iam_policy_document" "lambda_event_sub" {
  statement {
    sid    = "LambdaEventSubDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams",
      "dynamodb:UpdateItem"
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

resource "aws_iam_policy" "lambda_event_sub" {
  name   = "${title(var.namespace)}LambdaEventSubPolicy"
  policy = data.aws_iam_policy_document.lambda_event_sub.json
}

