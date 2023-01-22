variable "target_group" {
  description = "target group arn of chat stat load balancer"
  type        = string
}

variable "private_subnets" {
  description = "private subnets for chat stat"
  type        = list(string)
}

variable "public_subnets" {
  description = "public subnets for chat stat"
  type        = list(string)
}

variable "security_group_ecs_task" {
  description = "security group for chat stat"
  type        = string
}

variable "ecr_repo_api" {
  description = "ecr repo for chat stat api"
  type        = string
}
