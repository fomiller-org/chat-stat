resource "aws_internet_gateway" "chat_stat" {
  vpc_id = aws_vpc.chat_stat_main.id
  tags = {
    Name = "Chat Stat VPC IG"
  }
}
