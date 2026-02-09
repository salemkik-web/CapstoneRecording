resource "aws_db_instance" "wordpress" {
  allocated_storage    = 20
  engine               = "mariadb"
  engine_version       = "10.5"
  instance_class       = "db.t2.micro"
  name                 = var.db_name
  username             = var.db_user
  password             = var.db_password
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.wp_subnet_group.id
}

resource "aws_db_subnet_group" "wp_subnet_group" {
  name       = "wp-subnet-group"
  subnet_ids = [aws_subnet.private.id]
}
