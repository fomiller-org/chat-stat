output "cs_ecs_cluster_arn" {
  value = aws_ecs_cluster.chat_stat.arn
}

output "cs_api_task_def_arn" {
  value = aws_ecs_task_definition.chat_stat_api.arn
}
