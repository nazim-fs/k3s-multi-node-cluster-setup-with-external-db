variable "vpc_id" {}
variable "public_ip" {}

resource "aws_security_group" "k3s-bastion-sg" {
  name        = "k3s-bastion-sg"
  description = "Bastion Node SG"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public_ip}/32"]
  }

  # Application ports are Optional, in case if any app needs to be accessed
  ingress {
    description = "Application Ports"
    from_port   = 30007
    to_port     = 30010
    protocol    = "tcp"
    cidr_blocks = ["${var.public_ip}/32"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.public_ip}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
