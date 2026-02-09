data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

resource "aws_launch_template" "lt" {
  image_id      = data.aws_ami.amazon.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    db_host     = aws_db_instance.db.address
  }))
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "cpu-target-tracking-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
