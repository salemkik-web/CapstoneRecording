resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux2.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public1.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = { Name = "bastion-host" }
}


resource "aws_instance" "test_ec2" {
  ami           = data.aws_ami.amazon_linux2.id # Amazon Linux 2 in us-east-1
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public1.id
  vpc_security_group_ids = [
  aws_security_group.bastion_sg.id,
  aws_security_group.alb_sg.id
]
  key_name      =  var.key_name # Replace with your existing keypair

user_data = base64encode(templatefile("userdata.sh", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    db_host     = aws_db_instance.wordpress.endpoint
  }))

  tags = {
    Name = "Test-UserData-EC2"
  }
}
