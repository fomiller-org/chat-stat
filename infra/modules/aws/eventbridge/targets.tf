resource "aws_cloudwatch_event_target" "cs_api_ecr_target" {
  target_id = "${var.namespace}-${var.app_prefix}-api-ecs"
  arn       = var.cs_ecs_cluster_arn
  rule      = aws_cloudwatch_event_rule.cs_api_ecr_rule.name
  role_arn  = data.aws_iam_role.eventbridge_ecs_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = var.cs_api_task_def_arn
  }
}

# resource "aws_cloudwatch_event_target" "cs_bot_ecr_target" {
#   target_id = "${var.app_prefix}-bot-ecs"
#   arn       = var.cs_ecs_cluster_arn
#
#   ecs_target {
#     task_count          = 1
#     task_definition_arn = var.cs_bot__task_def_arn
#   }
# }
