# Dedicated VPC
resource "aws_vpc" "dedicated-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "Dedicated K3S VPC"
  }
}

# Public subnet
resource "aws_subnet" "public-subnet" {
  depends_on              = [aws_vpc.dedicated-vpc]
  vpc_id                  = aws_vpc.dedicated-vpc.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.2.0/24"
  tags = {
    "Name" = "Public Subnet"
  }
}

# Private subnet
resource "aws_subnet" "private-subnet" {
  depends_on = [aws_vpc.dedicated-vpc]
  vpc_id     = aws_vpc.dedicated-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "Private Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  depends_on = [aws_vpc.dedicated-vpc]
  vpc_id     = aws_vpc.dedicated-vpc.id
  tags = {
    "Name" = "Internet Gateway"
  }
}

# Create public route table
resource "aws_route_table" "public-route" {
  depends_on = [aws_internet_gateway.igw]
  vpc_id     = aws_vpc.dedicated-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "Public Route Table"
  }
}

# Associate Route Table to IGW
resource "aws_route_table_association" "public_route_table_association" {
  depends_on     = [aws_route_table.public-route]
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route.id
}

# Elastic IP for NAT
resource "aws_eip" "nat-gw-ip" {
  vpc = true
  tags = {
    "Name" = "NAT GW EIP"
  }
}

# NAT GW
resource "aws_nat_gateway" "nat-gw" {
  depends_on    = [aws_internet_gateway.igw]
  allocation_id = aws_eip.nat-gw-ip.id
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    "Name" = "NAT Gateway"
  }
}

# Create private route table
resource "aws_route_table" "private-route" {
  depends_on = [aws_nat_gateway.nat-gw]
  vpc_id     = aws_vpc.dedicated-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    "Name" = "Private Route Table"
  }
}

# Associate Route Table to NAT GW
resource "aws_route_table_association" "private_route_table_association" {
  depends_on     = [aws_route_table.private-route]
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route.id
}

output "vpc_id" {
  value = aws_vpc.dedicated-vpc.id
}

output "public_subnet_cidr_block" {
  value = aws_subnet.public-subnet.cidr_block
}

output "public_subnet_id" {
  value = aws_subnet.public-subnet.id
}

output "private_subnet_cidr_block" {
  value = aws_subnet.private-subnet.cidr_block
}

output "private_subnet_id" {
  value = aws_subnet.private-subnet.id
}
