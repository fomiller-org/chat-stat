resource "aws_subnet" "public_subnets" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.chat_stat_main.id
    cidr_block = element(var.public_subnet_cidrs, count.index)
    availability_zone = element(var.azs, count.index)
    tags = {
        Name = "Public Subnet ${count.index + 1}"
    }
}

resource "aws_subnet" "private_subnets" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.chat_stat_main.id
    cidr_block = element(var.private_subnet_cidrs, count.index)
    availability_zone = element(var.azs, count.index)
    tags = {
        Name = "Private Subnet ${count.index + 1}"
    }
}

resource "aws_route_table" "chat_stat_rt" {
    vpc_id = aws_vpc.chat_stat_main.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.chat_stat.id
    }
    
    tags = {
        Name = "Chat Stat route table"
    }
}

resource "aws_route_table_association" "chat_stat" {
    count = length(var.public_subnet_cidrs) 
    subnet-id = element(aws_subnet.public_subnet_cidrs[*].id, count.index)
    route_table_id = aws_route_table.chat_stat_rt.id
}
