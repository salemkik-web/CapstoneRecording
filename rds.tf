resource "aws_db_instance" "wordpress" {
  identifier        = "wordpress-db"
  engine            = "mariadb"
  engine_version    = "10.5"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  username          = var.db_user
  password          = var.db_password
  db_name           = var.db_name   # correct attribute
  parameter_group_name = "default.mariadb10.5"

  publicly_accessible = false
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_group_name      = aws_db_subnet_group.wordpress.name
}
