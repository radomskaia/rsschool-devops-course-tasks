output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = aws_subnet.private[*].id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_eip.bastion.public_ip
}

output "nat_gateway_ip" {
  description = "IP address of NAT Gateway"
  value       = var.nat_gateway_enabled ? aws_eip.nat_eip[0].public_ip : aws_eip.nat_instance[0].public_ip
}
