# Use the common AMI for all EC2 instances
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2.id  # Reuse single data resource
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-host"
  }
}
