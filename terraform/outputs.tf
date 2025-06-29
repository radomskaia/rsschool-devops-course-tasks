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

output "k3s_master_private_ip" {
  description = "Private IP of the k3s master node"
  value       = aws_instance.k3s_master.private_ip
}

output "k3s_worker_private_ips" {
  description = "Private IPs of the k3s worker nodes"
  value       = aws_instance.k3s_worker[*].private_ip
}

output "k3s_connection_instructions" {
  description = "Instructions to connect to the k3s cluster"
  value = <<EOF
1. Connect to the bastion host:
   ssh -i /path/to/your/key.pem ec2-user@${aws_eip.bastion.public_ip}

2. From the bastion host, set up kubectl:
   ./setup_kubectl.sh ${aws_instance.k3s_master.private_ip}

3. Verify the cluster is running:
   kubectl get nodes

4. Verify the NGINX pod is running:
   kubectl get pod nginx
   kubectl get all --all-namespaces | grep nginx

5. For accessing from local computer:
   Run the provided script: ./scripts/setup_local_access.sh /path/to/your/key.pem
EOF
}
