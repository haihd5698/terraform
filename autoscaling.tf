resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "autoscalingWeb-"
  key_name      = "main-key1"
  image_id      = "ami-035ecd4b3adc5147e"
  instance_type = "t2.micro"
  # user_data = "${file("config_server.sh")}"
  security_groups = [aws_security_group.WebserverGroup.id]
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "asg_test" {
  name                      = "asg-test"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.public.id, aws_subnet.public2.id]
  tag {
    key = "Name"
    value = "asg"
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }
}
resource "aws_autoscaling_policy" "cpu_policy_scaleup" {
  name                   = "asg-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg_test.name
}
resource "aws_autoscaling_policy" "cpu_policy_scaledown" {
  name                   = "asg-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg_test.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_scaleup" {
  alarm_name          = "scaleup"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_test.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu_policy_scaleup.arn]
}
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_scaledown" {
  alarm_name          = "scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_test.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu_policy_scaleup.arn]
}
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg_test.id
  elb                    = aws_elb.elb.id
}

# resource "aws_nat_gateway" "public" {
#   connectivity_type = "private"
#   subnet_id         = aws_subnet.public.id
# }
# resource "aws_nat_gateway" "public2" {
#   connectivity_type = "private"
#   subnet_id         = aws_subnet.public2.id
# }
