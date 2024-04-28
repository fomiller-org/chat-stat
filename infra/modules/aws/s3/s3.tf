resource "aws_s3_bucket" "chat_stat" {
  bucket = "${var.namespace}-${var.environment}-chat-stat"

  object_lock_enabled = false

  tags = {
    Owner       = "Forrest Miller"
    Email       = "forrestmillerj@gmail.com"
    Environment = var.environment
  }
}

