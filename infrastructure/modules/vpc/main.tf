###################################
### VPC
###################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-main-vpc" }
}

###################################
### Public Subnets
###################################
resource "aws_subnet" "public" {
  for_each = zipmap(var.availability_zones, var.public_subnets_cidrs)
  vpc_id   = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.name_prefix}-public-${each.key}"
    "kubernetes.io/role/elb" = "1"
  }
}

###################################
### Private Subnets
###################################
resource "aws_subnet" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = split("-", each.key)[0]

  tags = {
    Name = "${var.name_prefix}-private-${each.key}"
    # Only K8s private subnets get the internal ELB tag
    "kubernetes.io/role/internal-elb" = length(regexall("k8s", each.key)) > 0 ? "1" : null
  }
}

###################################
### Internet Gateway
###################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

###################################
### Public Route Table
###################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

###################################
### NAT Gateway
###################################
resource "aws_eip" "nat" {
  domain = "vpc"  # Fixed: Changed from vpc = true
  tags = { Name = "${var.name_prefix}-nat-eip" }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = local.nat_subnet_id
  tags = { Name = "${var.name_prefix}-nat-gateway" }
  depends_on = [aws_internet_gateway.igw]
}

###################################
### Private Route Table
###################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = { Name = "${var.name_prefix}-private-rt" }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

