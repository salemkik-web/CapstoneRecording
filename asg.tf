data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "wp-lt-"
  image_id      = data.aws_ami.amazon.id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(
    templatefile("${path.root}/userdata.sh", {
      db_name     = var.db_name
      db_user     = var.db_user
      db_password = var.db_password
      db_host     = aws_db_instance.wordpress.endpoint
    })
  )
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.private.id]
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  target_group_arns    = [aws_lb_target_group.tg.arn]
  health_check_type    = "ELB"
  health_check_grace_period = 300
}
