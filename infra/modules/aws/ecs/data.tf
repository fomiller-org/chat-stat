data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ecr_image" "chat_stat_api" {
  repository_name = "${var.app_prefix}-api"
  image_tag       = "latest"
}

data "aws_security_group" "chat_stat_ecs_task_sg" {
  name = "${var.app_prefix}-task-security-group"
}

data "aws_vpc" "chat_stat_main" {
  id = "vpc-02ea05e95f71ce33d"
  # filter {
  #   name = "fomiller-chat-stat-vpc"
  # }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.chat_stat_main.id
  tags = {
    Tier = "Private"
  }
}

data "aws_lb_target_group" "chat_stat" {
  name = "${var.app_prefix}-target-group"
}
