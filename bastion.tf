data "aws_ami" "amazon" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
}
