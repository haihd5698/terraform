provider "aws" {
    region = "ap-southeast-1"
    access_key = "AKIAUQA7DY67NC2NVGUY"
    secret_key = "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"

}

# VPC
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
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.apps.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-southeast-1b"
    tags = {
        Name = "privatesubnet"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.past1.id
}

# security groups

resource "aws_security_group" "BastionGroup" {
    name        = "BastionGroup"
    description = "no"
    vpc_id      = aws_vpc.apps.id

    ingress {
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }


    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "BastionGroup"
    }
}
resource "aws_security_group" "WebserverGroup" {
    name        = "WebserverGroup"
    description = "no"
    vpc_id      = aws_vpc.apps.id

    ingress {
        description      = "HTTPs from VPC"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
        description      = "HTTP from VPC"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
        description      = "SSH from Bastion"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["10.0.1.10/32"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "WebserverGroup"
    }
}
resource "aws_security_group" "rds" {
    name        = "rds"
    description = "no"
    vpc_id      = aws_vpc.apps.id

    ingress {
        description      = "MYSQL"
        from_port        = 3306
        to_port          = 3306
        protocol         = "tcp"
        cidr_blocks      = ["10.0.0.0/16"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "Rds"
    }
}
resource "aws_network_interface" "BastionInterface" {
    subnet_id = aws_subnet.public.id
    private_ips = [ "10.0.1.10" ]
    security_groups = [aws_security_group.BastionGroup.id]
}
resource "aws_network_interface" "WebserverInterface" {
    subnet_id = aws_subnet.public.id
    private_ips = ["10.0.1.20"]
    security_groups = [aws_security_group.WebserverGroup.id]
}
resource "aws_eip" "BastionEIP" {
    vpc = true
    network_interface = aws_network_interface.BastionInterface.id
    associate_with_private_ip = "10.0.1.10"
    depends_on = [aws_internet_gateway.past1]
}
resource "aws_eip" "WebEIP" {
    vpc = true
    network_interface = aws_network_interface.WebserverInterface.id
    associate_with_private_ip = "10.0.1.20"
    depends_on = [aws_internet_gateway.past1]
}
resource "aws_instance" "Bastion" {
    ami = "ami-0d058fe428540cd89"
    instance_type = "t2.micro"
    key_name = "main-key1"
    # user_data = 
    # subnet_id = aws_subnet.public.id
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.BastionInterface.id
    }
    tags = {
        Name = "Bastion"
    }
}
resource "aws_instance" "Source" {
    ami = "ami-0d058fe428540cd89"
    instance_type = "t2.micro"
    key_name = "main-key1"
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.WebserverInterface.id
    }
    user_data = "${file("config_server.sh")}"
    tags = {
        Name = "WebServer"
    }
}

resource "aws_db_subnet_group" "dbsubnetgr" {
    name       = "database subnets"
    subnet_ids = [aws_subnet.private.id, aws_subnet.public.id]

    tags = {
        Name = "DB subnet group"
    }
}
resource "aws_db_instance" "datapast1" {
    allocated_storage    = 10
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t2.micro"
    name                 = "datapast1"
    username             = "root"
    password             = "123456789"
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot  = true
    publicly_accessible  = false
    vpc_security_group_ids = [aws_security_group.rds.id]
    db_subnet_group_name  = aws_db_subnet_group.dbsubnetgr.name
}
