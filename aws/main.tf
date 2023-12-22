locals {
  # Use the path for your private key
  pub_ssh_key_file = "~/.ssh/id_rsa.pub"

  # https://aws.amazon.com/ec2/instance-types/
  control_plane_instance_type = "t2.medium"
  worker_plane_instance_type  = "t2.medium"
  load_balancer_instance_type = "t2.micro"

  control_plane_nodes = [
    "control-plane-01",
    "control-plane-02",
  ]

  worker_plane_nodes = [
    "worker-plane-01",
  ]
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "k8s_cluster-ssh_key"
  public_key = file(local.pub_ssh_key_file)

  tags = {
    Name = "k8s_cluster-ssh_key"
  }
}

module "control_plane" {
  source = "./ec2-instance"
  for_each = toset(local.control_plane_nodes)

  hostname    = each.key
  ami_id      = data.aws_ami.ami.id
  ssh_key_id  = aws_key_pair.ssh_key.id
  instance_type = local.control_plane_instance_type
  vpc_subnet_id   = aws_subnet.vpc_subnet.id
  security_groups = [aws_security_group.control_plane.id]
}

module "worker_plane" {
  source = "./ec2-instance"
  for_each = toset(local.worker_plane_nodes)

  hostname    = each.key
  ami_id      = data.aws_ami.ami.id
  ssh_key_id  = aws_key_pair.ssh_key.id
  instance_type = local.worker_plane_instance_type
  vpc_subnet_id   = aws_subnet.vpc_subnet.id
  security_groups = [aws_security_group.worker_plane.id]
}

module "load_balancer" {
  source = "./ec2-instance"
  for_each = toset(["load-balancer"])

  hostname    = each.key
  ami_id      = data.aws_ami.ami.id
  ssh_key_id  = aws_key_pair.ssh_key.id
  instance_type = local.load_balancer_instance_type
  vpc_subnet_id   = aws_subnet.vpc_subnet.id
  security_groups = [aws_security_group.load_balancer.id]
}

output "ips" {
  value = [
    module.control_plane,
    module.worker_plane,
    module.load_balancer
  ]
}
