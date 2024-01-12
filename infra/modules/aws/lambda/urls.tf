resource "aws_lambda_function_url" "twitch_event_sub_webhook" {
  function_name      = aws_lambda_function.twitch_event_sub_webhook.function_name
  authorization_type = "NONE"
}
