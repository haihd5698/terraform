resource "aws_elb" "elb" {
  name               = "test-elb"
  # availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  security_groups = [aws_security_group.sg_elb.id]
  subnets = [aws_subnet.public.id, aws_subnet.public2.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb"
  }
}
