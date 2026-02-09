resource "aws_db_subnet_group" "db_subnets" {
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "db" {
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  skip_final_snapshot    = true
}
