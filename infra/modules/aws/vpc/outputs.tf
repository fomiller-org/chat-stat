output "load_balancer_ip" {
    value = aws_lb.chat_stat.dns_name
}
