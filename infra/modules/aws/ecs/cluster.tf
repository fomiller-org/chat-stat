resource "aws_ecs_cluster" "chat_stat" {
  name = "${var.namespace}-${var.app_prefix}-cluster"
}
