resource "aws_dynamodb_table" "chat_stat" {
  name         = "${var.namespace}-chat-stat"
  hash_key     = "StreamID"
  billing_mode = "PAY_PER_REQUEST"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "StreamID"
    type = "S"
  }
}
