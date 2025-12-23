resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.name_prefix}-main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  for_each   = zipmap(var.availability_zones, var.public_subnets_cidrs)
  cidr_block = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name_prefix}-public-${each.key}"
  }
}


resource "aws_subnet" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = split("-", each.key)[0]
  tags = {
    Name = "${var.name_prefix}-private-${each.key}"
  }
}


###################################
###  Internet Gateway
###################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

###################################
### Public Route Table
###################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Public subnets route directly to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

###################################
# Associate both public subnets with the public route table
###################################

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


###################################
### NAT Gateway (used for private subnet internet access)
###################################
resource "aws_eip" "nat" {
  tags = {
    Name = "${var.name_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = local.nat_subnet_id  # automatically picks the first public subnet

  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}


###################################
# --- Private Route Table
###################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Route to the NAT gateway for outbound internet access
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.name_prefix}-private-rt"
  }
}

#############################################
# Private Route Table Associations (All Private Subnets)
#############################################

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}


resource "aws_db_subnet_group" "private" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = local.db_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }
}
