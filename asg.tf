data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
resource "aws_launch_template" "lt" {
  name_prefix   = "wp-lt"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_group_names = [aws_security_group.ec2_sg.name]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    db_host     = aws_db_instance.wordpress.endpoint
  }))
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
}
