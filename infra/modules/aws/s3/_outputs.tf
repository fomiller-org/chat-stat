output "s3_bucket_name_chat_stat" {
  value = aws_s3_bucket.chat_stat.id
}

output "s3_bucket_arn_chat_stat" {
  value = aws_s3_bucket.chat_stat.arn
}
