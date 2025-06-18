resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = var.bastion_key_name

  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "${var.vpc_name}-bastion-host"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "bastion" {
  domain   = "vpc"
  instance = aws_instance.bastion.id

  tags = {
    Name = "${var.vpc_name}-bastion-eip"
  }
}
