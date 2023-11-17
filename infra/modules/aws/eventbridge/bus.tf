resource "aws_cloudwatch_event_bus" "chat_stat" {
  name = "${var.app_prefix}-bus"
}
