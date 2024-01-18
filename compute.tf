# Create the EC2 instance
resource "aws_instance" "subspace_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subspace_public_subnet.id
  vpc_security_group_ids = [aws_security_group.subspace_sg.id]

  tags = {
    Name        = "subspace-vpn"
    Environment = var.environment
    Owner       = var.owner
    Terraform   = "true"
  }
}

# Create the Elastic IP
resource "aws_eip" "subspace_eip" {
  instance = aws_instance.subspace_server.id

  tags = {
    Name        = "subspace-vpn"
    Environment = var.environment
    Owner       = var.owner
    Terraform   = "true"
  }
}

# Data source for Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
