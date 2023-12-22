resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "k8s_cluster-vpc"
  }
}

resource "aws_subnet" "vpc_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s_cluster-subnet"
  }
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "k8s_cluster-vpc_igw"
  }
}

resource "aws_route_table" "vpc_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  route {
    cidr_block =  aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }


  tags = {
    Name = "k8s_cluster-vpc_route_table"
  }
}

resource "aws_route_table_association" "vpc_subnet_rta" {
  subnet_id      = aws_subnet.vpc_subnet.id
  route_table_id = aws_route_table.vpc_route_table.id
}

resource "aws_security_group" "control_plane" {
  name   = "k8s_cluster-control_plane_sg"
  vpc_id = aws_vpc.vpc.id

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # etcd
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "TCP"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  # kube-apiserver
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  # kubelet
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "TCP"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  # kube-scheduler
  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "TCP"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  # kube-controller-manager
  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "TCP"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s_cluster-control_plane_sg"
  }
}

resource "aws_security_group" "worker_plane" {
  name   = "k8s_cluster-worker_plane_sg"
  vpc_id = aws_vpc.vpc.id

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # kubelet
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "TCP"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  # nodePort services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s_cluster-worker_plane_sg"
  }
}

resource "aws_security_group" "load_balancer" {
  name   = "k8s_cluster-load_balancer_sg"
  vpc_id = aws_vpc.vpc.id

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # nginx listener
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s_cluster-load_balancer_sg"
  }
}
