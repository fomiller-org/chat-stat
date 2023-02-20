resource "aws_ecs_cluster" "chat_stat" {
  name = "${var.app_prefix}-cluster"
}
