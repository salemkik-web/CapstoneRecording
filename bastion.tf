resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amzn2.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-host"
  }
}
