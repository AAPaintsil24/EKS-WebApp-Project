#############################################
# Security Group: Load Balancer (HTTP only)
#############################################
resource "aws_security_group" "load_balancer" {
  name        = "${var.name_prefix}-alb_sg"
  description = "Allow HTTP only from public"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb_sg"
  }
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
# Security Group: Auto Scaling Group Instances
#############################################
resource "aws_security_group" "autoscaling_group" {
  name        = "${var.name_prefix}-asg_sg"
  description = "Allow HTTP from ALB SG and SSH from Bastion SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from ALB SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  ingress {
    description     = "Allow SSH from Bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-asg_sg"
  }
}

#############################################
# Security Group: Database
#############################################
resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-db_sg"
  description = "Allow DB traffic from ASG SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow DB traffic from ASG SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp" # MYSQL/Aurora also works with "tcp"
    security_groups = [aws_security_group.autoscaling_group.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-db_sg"
  }
}


