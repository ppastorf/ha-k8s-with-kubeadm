variable "hostname" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "ssh_key_id" {
  type = string
}

variable "vpc_subnet_id" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

resource "aws_network_interface" "net_if" {
  subnet_id       = var.vpc_subnet_id
  security_groups = var.security_groups

  tags = {
    Name = "k8s_cluster-${var.hostname}-netif"
  }
}

resource "aws_eip" "eip" {
  domain   = "vpc"
  network_interface = aws_network_interface.net_if.id

  tags = {
    Name = "k8s_cluster-${var.hostname}-eip"
  }
}

resource "aws_instance" "instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key_id

  network_interface {
    network_interface_id = aws_network_interface.net_if.id
    device_index         = 0
  }

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname ${var.hostname}
  EOF

  tags = {
    Name = "k8s_cluster-${var.hostname}"
  }
}

output "private_ip" {
  value = aws_eip.eip.private_ip
}

output "public_ip" {
  value = aws_eip.eip.public_ip
}
