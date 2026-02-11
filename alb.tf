# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "wp-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
  enable_deletion_protection = false

  tags = {
    Name = "wp-alb"
  }
}

# Target Group for WordPress EC2 instances
resource "aws_lb_target_group" "wp_tg" {
  name        = "wp-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  deregistration_delay = 30    # Ensures clean shutdown on scale-in

 health_check {
    path                = "/index.php"   # ✅ updated from "/" to "/index.php"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 5              # Require 5 consecutive successes
    unhealthy_threshold = 3              # Mark unhealthy after 3 failures
    matcher             = "200-399"      # ✅ allows WordPress redirects
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp_tg.arn
  }
}
