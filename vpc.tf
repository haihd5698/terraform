
resource "aws_vpc" "apps" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "terraformtest"
    }
}
resource "aws_internet_gateway" "past1" {
    vpc_id = aws_vpc.apps.id
}

resource "aws_route_table" "past1" {
    vpc_id = aws_vpc.apps.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.past1.id
    }
    tags = {
      Name = "past1"
    }
}
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.apps.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-southeast-1a"
    tags = {
        Name = "publicsubnet"
    }
}
resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.apps.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "ap-southeast-1b"
    tags = {
        Name = "publicsubnet"
    }
}
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.apps.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-southeast-1b"
    tags = {
        Name = "privatesubnet"
    }
}
resource "aws_subnet" "private2" {
    vpc_id = aws_vpc.apps.id
    cidr_block = "10.0.20.0/24"
    availability_zone = "ap-southeast-1c"
    tags = {
        Name = "privatesubnet"
    }
}
resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.past1.id
}
