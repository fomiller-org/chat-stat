resource "aws_lambda_event_source_mapping" "event_sub" {
  event_source_arn  = var.dynamodb_table_stream_arn_chat_stat
  function_name     = aws_lambda_function.twitch_event_sub.function_name
  starting_position = "LATEST"
  batch_size        = 1
}
