resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  description = "Allow HTTP Inbound"
  vpc_id = aws_vpc.main.id

  ingress = {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_block = ["0.0.0.0/0"]
  }

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_block = ["0.0.0.0/10"]
  }

  tags = { Name = "Alg-sg"}
}

resource "aws_security_group" "instance_sg" {
  name = "instance-sg"
  description = "Allow SSH, backend ,etc"
  vpc_id = aws_vpc.main.id

  ingress  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port = 2377
    to_port = 2377
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = { Name = "Instance-sg"}
}