resource "aws_launch_template" "lt" {
  name_prefix   = "wp-lt"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    db_host     = aws_db_instance.wordpress.endpoint
  }))
}
