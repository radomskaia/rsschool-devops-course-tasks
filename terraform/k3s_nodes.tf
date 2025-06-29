resource "aws_instance" "k3s_master" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.k3s_instance_type
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.k3s_master_sg.id]
  key_name               = var.bastion_key_name

  user_data = templatefile("../user_data/k3s_master.sh", {
    k3s_version = var.k3s_version
    k3s_token   = var.k3s_token
  })

  tags = {
    Name = "${var.vpc_name}-k3s-master"
  }

  depends_on = [var.nat_gateway_enabled ? aws_nat_gateway.nat[0] : aws_instance.nat_instance[0]]
}

resource "aws_instance" "k3s_worker" {
  count                  = var.worker_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.k3s_instance_type
  subnet_id              = aws_subnet.private[1 % length(var.private_subnet_cidrs)].id
  vpc_security_group_ids = [aws_security_group.k3s_worker_sg.id]
  key_name               = var.bastion_key_name

  user_data = templatefile("../user_data/k3s_worker.sh", {
    k3s_version   = var.k3s_version
    k3s_master_ip = aws_instance.k3s_master.private_ip
    k3s_token     = var.k3s_token
  })

  tags = {
    Name = "${var.vpc_name}-k3s-worker-${count.index + 1}"
  }

  depends_on = [aws_instance.k3s_master, var.nat_gateway_enabled ? aws_nat_gateway.nat[0] : aws_instance.nat_instance[0]]
}
