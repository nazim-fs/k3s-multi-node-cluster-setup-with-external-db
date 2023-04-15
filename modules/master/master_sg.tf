variable "vpc_id" {}
variable "public_subnet_cidr_block" {}
variable "private_subnet_cidr_block" {}

resource "aws_security_group" "k3s-master-sg" {
  name        = "k3s-master-sg"
  description = "Master Nodes SG"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr_block]
  }

  ingress {
    description = "Kube-API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr_block]
  }

  ingress {
    description = "Kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr_block]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.public_subnet_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
