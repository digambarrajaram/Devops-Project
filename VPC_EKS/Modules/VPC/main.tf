resource "aws_vpc" "VPC" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "VPC"
  }
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "IGW"
  }
  depends_on = [aws_vpc.VPC]
}

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id     = aws_vpc.VPC.id
  cidr_block = var.public_subnet_cidr_block[count.index]
  availability_zone = var.availability_zone[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                                      = "Public Subnet ${count.index}"
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "Public Route Table"
  }
  route {
    cidr_block = var.route
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  count = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id = aws_vpc.VPC.id
  cidr_block = var.private_subnet_cidr_block[count.index]
  availability_zone = var.availability_zone[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name                                      = "Private Subnet ${count.index}"
    "kubernetes.io/role/internal-elb"         = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "Private Route Table"
  }
  route {
    cidr_block = var.route
    gateway_id = aws_nat_gateway.nat_gw[0].id
  }
}

resource "aws_eip" "nat_eip" {
  count = length(aws_subnet.public_subnet)
  tags = {
    Name = "NAT EIP"
  }
}


resource "aws_nat_gateway" "nat_gw" {
  count         = length(aws_subnet.public_subnet)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table_association" "nat_asso" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}


