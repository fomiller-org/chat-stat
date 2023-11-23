resource "aws_vpc" "chat_stat_main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.namespace}-${var.app_prefix}-vpc"
  }
}
