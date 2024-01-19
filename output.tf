output "ec2_instance_ip" {
  value = aws_instance.subspace_server.public_ip
}

output "key_name_value" {
  value = var.key_name
}