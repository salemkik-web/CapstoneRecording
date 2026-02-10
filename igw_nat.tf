# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "training-igw" }
}

# EIP + NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags       = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw, aws_eip.nat]
  tags          = { Name = "nat-gateway" }

  timeouts {
    create = "15m"
    delete = "15m"
  }
}