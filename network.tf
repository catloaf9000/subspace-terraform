terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "subspace_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name        = "subspace-vpn"
    Environment = var.environment
    Owner       = var.owner
    Terraform   = "true"
  }
}

resource "aws_subnet" "subspace_public_subnet" {
  vpc_id            = aws_vpc.subspace_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "subspace-public-subnet"
    Environment = var.environment
    Owner       = var.owner
    Terraform   = "true"
  }
}

resource "aws_internet_gateway" "subspace_igw" {
  vpc_id = aws_vpc.subspace_vpc.id

  tags = {
    Name        = "subspace-igw"
    Environment = var.environment
    Owner       = var.owner
    Terraform   = "true"
  }
}

resource "aws_route_table" "subspace_public_subnet_route_table" {
  vpc_id = aws_vpc.subspace_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.subspace_igw.id
  }

  tags = {
    Name        = "subspace-public-subnet-route-table"
    Environment = var.environment
    Owner       = var.owner
    Terraform   = "true"
  }
}

resource "aws_route_table_association" "subspace_public_subnet_association" {
  subnet_id      = aws_subnet.subspace_public_subnet.id
  route_table_id = aws_route_table.subspace_public_subnet_route_table.id
}