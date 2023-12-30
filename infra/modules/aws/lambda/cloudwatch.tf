resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "event_sub" {
  name              = "/aws/lambda/${aws_lambda_function.event_sub.function_name}"
  retention_in_days = 7
}
