variable "vpc_id" {}
variable "public_subnet_cidr_block" {}

resource "aws_security_group" "k3s-worker-sg" {
  name        = "k3s-worker-sg"
  description = "Worker Nodes SG"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr_block]
  }

  # Application ports are Optional, in case if any app needs to be accessed
  ingress {
    description = "Application Ports"
    from_port   = 30007
    to_port     = 30010
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr_block]
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
