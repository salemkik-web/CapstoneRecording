#############################################
# AMI
#############################################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#############################################
# Launch Template
#############################################

resource "aws_launch_template" "wp_lt" {
  name_prefix   = "wp-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile {
    
     name = "LabRole"
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    db_host     = aws_db_instance.db.address
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wordpress-asg"
    }
  }
}

#############################################
# Auto Scaling Group
#############################################

resource "aws_autoscaling_group" "wp_asg" {
  name                = "wp-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = aws_subnet.private[*].id

  target_group_arns = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.wp_lt.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "wordpress-asg"
    propagate_at_launch = true
  }
}

#############################################
# Auto Scaling Policy (CPU > 50%)
#############################################

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.wp_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
