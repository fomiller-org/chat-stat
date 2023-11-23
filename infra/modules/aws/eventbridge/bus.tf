resource "aws_cloudwatch_event_bus" "chat_stat" {
  name = "${var.namespace}-${var.app_prefix}-bus"
}
