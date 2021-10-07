
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
