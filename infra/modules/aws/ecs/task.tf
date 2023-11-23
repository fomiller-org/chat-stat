resource "aws_ecs_task_definition" "chat_stat_api" {
  family                   = "${var.namespace}-${var.app_prefix}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 1024
  memory                   = 2048

  container_definitions = <<DEFINITION
[
  {
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.ecr_repo_api}:${var.ecr_tag}",
    "cpu": 1024,
    "memory": 2048,
    "name": "${var.namespace}-${var.app_prefix}-api",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
DEFINITION
}

# resource "aws_ecs_task_definition" "chat_stat_bot" {
#   family                   = "${var.app_prefix}-bot"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["EC2"]
#   cpu                      = 1024
#   memory                   = 2048
#
#   container_definitions = <<DEFINITION
# [
#   {
#     "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.ecr_repo_api_name}:${var.ecr_tag}",
#     "cpu": 1024,
#     "memory": 2048,
#     "name": "${var.app_prefix}-bot",
#     "networkMode": "awsvpc",
#     "portMappings": [
#       {
#         "containerPort": 3000,
#         "hostPort": 3000
#       }
#     ]
#   }
# ]
# DEFINITION
# }
