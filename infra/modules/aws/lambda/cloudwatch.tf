resource "aws_cloudwatch_log_group" "event_sub" {
  name              = "/aws/lambda/${aws_lambda_function.twitch_event_sub.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "twitch_event_sub_webhook" {
  name              = "/aws/lambda/${aws_lambda_function.twitch_event_sub_webhook.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "twitch_record_manager" {
  name              = "/aws/lambda/${aws_lambda_function.twitch_record_manager.function_name}"
  retention_in_days = 7
}

