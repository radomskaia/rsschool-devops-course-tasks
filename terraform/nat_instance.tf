# cheaper way
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "nat_instance" {
  count         = var.nat_gateway_enabled ? 0 : 1
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.nat_instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = var.bastion_key_name

  vpc_security_group_ids = [aws_security_group.nat_instance[0].id]

  source_dest_check = false

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y iptables-services
              echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
              sysctl -p
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              iptables-save > /etc/iptables/rules.v4
              systemctl enable iptables
              systemctl start iptables
              EOF

  tags = {
    Name = "${var.vpc_name}-nat-instance"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "nat_instance" {
  count    = var.nat_gateway_enabled ? 0 : 1
  domain   = "vpc"
  instance = aws_instance.nat_instance[0].id

  tags = {
    Name = "${var.vpc_name}-nat-instance-eip"
  }
}

resource "aws_route" "private_nat_instance" {
  count                  = var.nat_gateway_enabled ? 0 : 1
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_instance[0].primary_network_interface_id
}

