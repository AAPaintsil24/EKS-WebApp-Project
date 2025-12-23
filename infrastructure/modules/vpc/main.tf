###################################
###  VPC AND SUBNETS
###################################
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
    "kubernetes.io/role/elb" = "1"
  }
}


resource "aws_subnet" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = split("-", each.key)[0]
  tags = {
    Name = "${var.name_prefix}-private-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"
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



#############################################
# Security Group: Bastion Host
#############################################
resource "aws_security_group" "bastion_host" {
  name        = "${var.name_prefix}-bh_sg"
  description = "Security group bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/32"] # Replace with your IP
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-bh_sg"
  }
}


#############################################
# Bastion Host
#############################################

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.bastion_host.id]
  subnet_id = local.bastion_subnet_id  # automatically picks the first public subnet
  associate_public_ip_address = true
  key_name = var.key_name
  tags = {
    Name = "${var.name_prefix}-bastion"
  }
}








