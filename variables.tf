variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "Oleksii Mahurin"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "subspace-vpn-key"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
