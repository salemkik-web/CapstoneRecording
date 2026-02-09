resource "aws_db_subnet_group" "db" {
  name       = "wordpress-subnets"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "wordpress" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = var.db_user
  password             = var.db_password
  db_name              = var.db_name
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
}
