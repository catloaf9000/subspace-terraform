resource "aws_key_pair" "terraform_key" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name        = "subspace-vpn"
    Environment = var.environment
    Owner       = var.owner
    Terraform   = "true"
  }
}


resource "aws_security_group" "subspace_sg" {
  name        = "subspace_sg"
  description = "Security group for Subspace EC2 instance"
  vpc_id      = aws_vpc.subspace_vpc.id

  # Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "subspace-vpn"
    Environment = var.environment
    Owner       = var.owner
    Terraform   = "true"
  }
}