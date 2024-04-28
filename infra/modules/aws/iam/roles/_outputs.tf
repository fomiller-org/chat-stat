output "iam_role_name_lambda_twitch_event_sub" {
  value = aws_iam_role.lambda_twitch_event_sub.name
}

output "iam_role_arn_lambda_twitch_event_sub" {
  value = aws_iam_role.lambda_twitch_event_sub.arn
}

output "iam_role_name_lambda_twitch_event_sub_webhook" {
  value = aws_iam_role.lambda_twitch_event_sub_webhook.name
}

output "iam_role_arn_lambda_twitch_event_sub_webhook" {
  value = aws_iam_role.lambda_twitch_event_sub_webhook.arn
}

output "iam_role_name_lambda_twitch_record_manager" {
  value = aws_iam_role.lambda_twitch_record_manager.name
}

output "iam_role_arn_lambda_twitch_record_manager" {
  value = aws_iam_role.lambda_twitch_record_manager.arn
}

output "iam_role_name_sfn_chat_stat_logger" {
  value = aws_iam_role.sfn_chat_stat_logger.name
}

output "iam_role_arn_sfn_chat_stat_logger" {
  value = aws_iam_role.sfn_chat_stat_logger.arn
}

output "iam_role_name_lambda_timestream_query" {
  value = aws_iam_role.lambda_timestream_query.name
}

output "iam_role_arn_lambda_timestream_query" {
  value = aws_iam_role.lambda_timestream_query.arn
}
