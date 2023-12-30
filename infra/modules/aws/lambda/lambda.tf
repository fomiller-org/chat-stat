resource "aws_lambda_function" "hello_world" {
  function_name    = "${var.namespace}-${var.app_prefix}-${var.lambda_name}"
  role             = data.aws_iam_role.hello_world.arn
  handler          = "bootstrap"
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = data.archive_file.hello_world.output_base64sha256
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 10
}

data "aws_iam_role" "hello_world" {
  name = var.lambda_role
}


resource "aws_lambda_function" "event_sub" {
  function_name    = "${var.namespace}-${var.app_prefix}-event-sub"
  role             = var.iam_role_arn_lambda_event_sub
  handler          = "bootstrap"
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = data.archive_file.event_sub.output_base64sha256
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 10
}

