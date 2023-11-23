resource "aws_lb" "chat_stat" {
  name            = "${var.namespace}-${var.app_prefix}-lb"
  subnets         = aws_subnet.public_subnets[*].id
  security_groups = [aws_security_group.chat_stat_lb.id]
}

resource "aws_lb_target_group" "chat_stat" {
  name        = "${var.app_prefix}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.chat_stat_main.id
  target_type = "ip"
}

resource "aws_lb_listener" "chat_stat" {
  load_balancer_arn = aws_lb.chat_stat.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.chat_stat.id
    type             = "forward"
  }
}

