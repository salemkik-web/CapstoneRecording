

resource "aws_lb" "alb" {
  name               = "wp-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.public.id,
    aws_subnet.public2.id
  ]
  enable_deletion_protection = false
  tags = { Name = "wp-alb" }
}
# Target group for ALB
resource "aws_lb_target_group" "wp_tg" {
  name     = "wp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.wp_tg.arn]
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp_tg.arn
  }
}


