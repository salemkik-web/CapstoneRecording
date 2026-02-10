resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux2.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public1.id
  key_name      = var.key_name
  security_groups = [aws_security_group.bastion_sg.id]

  tags = { Name = "bastion-host" }
}
