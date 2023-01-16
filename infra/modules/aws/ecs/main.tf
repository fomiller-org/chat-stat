resource "aws_ecs_cluster" "chat_stat" {
  name = "${var.app_prefix}-api-cluster"
}

resource "aws_ecs_service" "chat_stat" {
  name            = "${var.app_prefix}-api-service"
  cluster         = aws_ecs_cluster.chat_stat.id
  task_definition = aws_ecs_task_definition.chat_stat.arn
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

resource "aws_ecs_task_definition" "chat_stat" {
  family                   = var.app_prefix
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 1024
  memory                   = 2048

  container_definitions = <<DEFINITION
[
  {
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.ecr_repo_api}",
    "cpu": 1024,
    "memory": 2048,
    "name": "fomiller-chat-stat-api",
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

