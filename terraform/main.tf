# ------------------ VPC ------------------
# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true # enables internal DNS
  enable_dns_hostnames = true # enables DNS for ec2 hostnames

  tags = { Name = "main-vpc" }
}

# ------------------ Subnets ------------------
# Public Subnet - mapped to allow public IP assignment
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet" }
}

#New Public subnet for load balancer 
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24" # New CIDR block
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-2" }
}


#Private subnet - no public IPs
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = { Name = "private-subnet" }
}

# ------------------ Internet Gateway ------------------
# internet gateway for outboound internet acess (for public subnet)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# ------------------ NAT Gateway ------------------
# elastic IP for NAT gateway(must be in a public subnet)
resource "aws_eip" "nat" {
  tags = { Name = "nat-eip" }
}

# NAT Gateway for internet access in private subnet without exposing the ip 
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags          = { Name = "nat-gateway" }
}

# ------------------ Route Tables ------------------
# Public route table - routes 0.0.0.0/0 to Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "public-rt" }
}

# Associate the public subnet with public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Associate the second public subnet with rt
resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}


# Private route table - routes 0.0.0.0/0 to NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-rt" }
}

#Associate the private subnet with private route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ------------------ Network ACLs ------------------
# NACL for public subnet (allow all HTTP/HTTPS/SSH)
resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]
  # Allow inbound HTTP
  ingress {
    rule_no    = 100
    protocol   = "6"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  # Allow HTTPS
  ingress {
    rule_no    = 110
    protocol   = "6"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  # Allow SSH
  ingress {
    rule_no    = 120
    protocol   = "6"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  # Allow all outbound
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "public-nacl" }
}

# NACL for Private subnet (little restrictive)
resource "aws_network_acl" "private_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private.id]
  # Allow HTTP from ALB/Public Subnet
  ingress {
    rule_no    = 100
    protocol   = "6"
    action     = "allow"
    cidr_block = aws_subnet.public.cidr_block
    from_port  = 80
    to_port    = 80
  }
  # Allow response ports
  ingress {
    rule_no    = 110
    protocol   = "6"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  # Outbound HTTP
  egress {
    rule_no    = 100
    protocol   = "6"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  tags = { Name = "private-nacl" }
}

# ------------------ Security Groups ------------------
# Security Group for ALB - allows HTTP from the world
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id
  # Inbound HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound All Traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ALB SG" }
}

# SG for EC2 in private subnet - only allow from ALB
resource "aws_security_group" "private_sg" {
  name   = "private-instance-sg"
  vpc_id = aws_vpc.main.id
  # Allow inbound only for ALB security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
    # Application ports
  ingress {
    from_port = 5000
    to_port = 5175
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Private SG" }
}

# SG for Jump Server 
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Bastion SG" }
}


# ------------------ Load Balancer ------------------
# Create ALB in private subnet
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id,aws_subnet.public_2.id]
  security_groups    = [aws_security_group.alb_sg.id]

  tags = { Name = "app-lb" }
}
# Target group for Ec2 instances
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
# Listner for ALB to forward traffic to target group
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ------------------ Launch Template & ASG ------------------
# Launch template for ec2 in private subnet
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    subnet_id                   = aws_subnet.private.id
    associate_public_ip_address = false
    security_groups             = [aws_security_group.private_sg.id]
  }
  key_name = var.ssh_key_name 
  lifecycle {
    create_before_destroy = true
  }
}
# Auto Scaling group using the launch template
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.private.id]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}
#--- Bastion Host (Jump Box) ---
resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  associate_public_ip_address = true
  key_name               = var.ssh_key_name
  security_groups        = [aws_security_group.bastion_sg.id]

  tags = { Name = "Bastion Host" }
}