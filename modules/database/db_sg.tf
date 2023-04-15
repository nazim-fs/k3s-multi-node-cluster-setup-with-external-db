variable "vpc_id" {}
variable "public_subnet_cidr_block" {}
variable "private_subnet_cidr_block" {}

resource "aws_security_group" "k3s-db-sg" {
  name        = "k3s-db-sg"
  description = "DB Node SG"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr_block]
  }

  ingress {
    description = "ETCD server"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr_block]
  }

  ingress {
    description = "ETCD"
    from_port   = 4001
    to_port     = 4001
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
