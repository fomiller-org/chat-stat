resource "aws_ecs_service" "chat_stat_api" {
  name            = "${var.app_prefix}-api-service"
  cluster         = aws_ecs_cluster.chat_stat.id
  task_definition = aws_ecs_task_definition.chat_stat_api.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    security_groups = [var.security_group_ecs_task]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = var.target_group
    container_name   = "${var.app_prefix}-api"
    container_port   = 3000
  }
}

# resource "aws_ecs_service" "chat_stat_bot" {
#   name            = "${var.app_prefix}-bot-service"
#   cluster         = aws_ecs_cluster.chat_stat.id
#   task_definition = aws_ecs_task_definition.chat_stat_bot.arn
#   desired_count   = 1
#   launch_type     = "EC2"
#
#   network_configuration {
#     security_groups = [var.security_group_ecs_task]
#     subnets         = var.private_subnets
#   }
#
#   load_balancer {
#     target_group_arn = var.target_group
#     container_name   = "${var.app_prefix}-bot"
#     container_port   = 3000
#   }
# }
