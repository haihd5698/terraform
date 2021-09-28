
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
        cidr_blocks      = ["${aws_instance.Bastion.private_ip}/32"]
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