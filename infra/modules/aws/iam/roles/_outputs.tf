output "iam_role_name_lambda_event_sub" {
  value = aws_iam_role.lambda_event_sub.name
}

output "iam_role_arn_lambda_event_sub" {
  value = aws_iam_role.lambda_event_sub.arn
}
