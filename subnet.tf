resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr[0]  # pick the first element
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[0]  # pick the first element
  tags = { Name = "private-subnet" }
}

resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [aws_subnet.private.id]   # still works because it's one subnet

  tags = {
    Name = "WordPress DB Subnet Group"
  }
}
