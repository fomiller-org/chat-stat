output "dynamodb_table_stream_arn_chat_stat" {
  value = aws_dynamodb_table.chat_stat.stream_arn
}
