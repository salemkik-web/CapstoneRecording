resource "aws_db_instance" "wordpress" {
  allocated_storage    = 20
  engine               = "mariadb"
  engine_version       = "10.5"
  instance_class       = "db.t3.micro"
  username             = var.db_user
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.wordpress.id
  publicly_accessible  = false
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
