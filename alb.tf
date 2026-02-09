resource "aws_lb" "alb" {
  name               = "wp-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id]
}
