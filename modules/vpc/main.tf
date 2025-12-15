#############################################
# Application Load Balancer (HTTP only)
#############################################
resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = [for s in aws_subnet.public : s.id]  # all public subnets

  enable_deletion_protection = true
  
  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

#############################################
# HTTP Listener (forwards traffic to target group)
#############################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

#############################################
# Bastion Host
#############################################

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = local.bastion_subnet_id  # automatically picks the first public subnet

  associate_public_ip_address = true

  tags = {
    Name = "${var.name_prefix}-bastion"
  }
}

#############################################
# Launch Template for ASG instances
#############################################
resource "aws_launch_template" "albert-lt" {
  name = "${var.name_prefix}-albert-lt"

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Block device
  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 20
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  # CPU options
  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  credit_specification {
    cpu_credits = "standard"
  }

  ebs_optimized = true

  # IAM role
  iam_instance_profile {
    name = "${var.name_prefix}_instance_profile"  # pass your instance profile name
  }

  # Shutdown behavior
  instance_initiated_shutdown_behavior = "terminate"

  # Spot instance
  instance_market_options {
    market_type = "spot"
  }

  # Metadata options
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Monitoring
  monitoring {
    enabled = true
  }

  # Network
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.autoscaling_group.id]
  }

  # Tags for instances created from this LT
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}-instance"
    }
  }

  # Tags for the launch template itself
  tags = {
    Name = "${var.name_prefix}-launch-template"
  }

  # User data
  user_data = filebase64("${path.module}/example.sh")
}

#############################################
# ALB Target Group (HTTP)
#############################################
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.name_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.name_prefix}-tg"
  }
}

#############################################
# Auto Scaling Group
#############################################
resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.name_prefix}-asg"
  max_size            = 8
  min_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.private["${var.availability_zones[0]}-app"].id, aws_subnet.private["${var.availability_zones[1]}-app"].id]  # app subnets

  launch_template {
    id      = aws_launch_template.albert-lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }
}


#############################################
# Auto Scaling Policies & CloudWatch Alarms
#############################################

# ----------------------------
# SCALE OUT (add instance)
# ----------------------------
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.name_prefix}-cpu-scale-out"
  scaling_adjustment     = 1                # Add 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name_prefix}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 50                # Scale out if CPU > 50%
  alarm_description   = "Scale out when average CPU > 70%"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

# -----------------------------
# SCALE IN (remove instance)
# -----------------------------
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.name_prefix}-cpu-scale-in"
  scaling_adjustment     = -1               # Remove 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.name_prefix}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30                 # Scale in if CPU < 30%
  alarm_description   = "Scale in when average CPU < 30%"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  
  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}



#########################################
# Generate a secure DB password
#########################################
resource "random_password" "db_instance" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#########################################
# Store password in Secrets Manager
#########################################
resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.name_prefix}-db-password"
  description = "RDS password for ${var.name_prefix} database"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_instance.result
}

#########################################
# RDS Multi-AZ instance
#########################################
resource "aws_db_instance" "main" {
  identifier             = "${var.name_prefix}-rds"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  username               = "albert"
  password               = jsondecode(aws_secretsmanager_secret_version.db_password_version.secret_string)
  db_name                = "mydb"
  multi_az               = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.private.name
  skip_final_snapshot    = true
  backup_retention_period = 7
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.name_prefix}-rds"
  }
}









