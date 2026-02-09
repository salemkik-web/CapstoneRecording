resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = { Name = "public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-west-2a"
  tags = { Name = "private-subnet" }
}

resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [aws_subnet.private.id]
  tags = { Name = "WordPress DB Subnet Group" }
}
