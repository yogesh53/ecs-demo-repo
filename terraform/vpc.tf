resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "my-public-subnet-1"
  }

}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"
  tags = {
    Name = "my-public-subnet-2"
  }

}
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "my-private-subnet-1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "my-private-subnet-2"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "my-igw"
  }
}
resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name = "my-eip"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "my-ngw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "my-public-rt"
  }
}

resource "aws_route_table_association" "public-rta-1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_route_table_association" "public-rta-2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "my-private-rt"
  }
}
resource "aws_route_table_association" "private-rta-1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private-rt.id
}
resource "aws_route_table_association" "private-rta-2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private-rt.id
}