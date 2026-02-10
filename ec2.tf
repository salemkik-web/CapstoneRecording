# Launch Template for WordPress EC2 instances
resource "aws_launch_template" "lt" {
  name_prefix   = "wp-lt"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Use the fixed userdata.sh
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    db_host     = aws_db_instance.wordpress.endpoint
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WordPress-EC2"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  depends_on = [
    aws_nat_gateway.nat,
    aws_db_instance.wordpress
  ]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  vpc_zone_identifier = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

  target_group_arns = [aws_lb_target_group.wp_tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300  # Give EC2 + WordPress enough time to start

  tag {
    key                 = "Name"
    value               = "AutoScale-WordPress"
    propagate_at_launch = true
  }
}

# Scaling Policy (optional)
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 120

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
