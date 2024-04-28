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
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      var.s3_bucket_arn_chat_stat
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject",
      "s3:GetObjectMetadata",
      "s3:AbortMultipartUpload",
    ]
    resources = [
      var.s3_bucket_arn_chat_stat,
      "${var.s3_bucket_arn_chat_stat}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_timestream_query" {
  name   = "${title(var.namespace)}LambaTimestreamQueryPolicy"
  policy = data.aws_iam_policy_document.lambda_timestream_query.json
}
