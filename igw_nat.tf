resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags          = { Name = "main-nat" }
}

resource "aws_eip" "nat" {
 # VPC argument removed
  depends_on = [aws_internet_gateway.igw]
}
