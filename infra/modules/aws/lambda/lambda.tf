resource "aws_lambda_function" "hello_world" {
  function_name    = "${var.app_prefix}-${var.lambda_name}"
  role             = data.aws_iam_role.hello_world.arn
  handler          = "lambda_hello"
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = data.archive_file.zip.output_base64sha256
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 10
}

data "aws_iam_role" "hello_world" {
  name = var.lambda_role
}
