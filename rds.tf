# DB Subnet Group
resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
  tags = { Name = "WordPress DB Subnet Group" }
}

# RDS Instance
resource "aws_db_instance" "wordpress" {
  allocated_storage     = 20
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  db_name               = var.db_name
  username              = var.db_user
  password              = var.db_password
  db_subnet_group_name  = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot   = true
  publicly_accessible   = false
  multi_az              = false
  storage_type          = "gp2"
}
