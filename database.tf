
resource "aws_db_subnet_group" "dbsubnetgr" {
    name       = "database subnets"
    subnet_ids = [aws_subnet.private.id, aws_subnet.private2.id]

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
