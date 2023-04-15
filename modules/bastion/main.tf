variable "public_subnet_id" {}
variable "ami_id" {}
variable "key_name" {}

resource "aws_instance" "k3s-bastion" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  monitoring             = true
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.k3s-bastion-sg.id]
  tags                   = { Name = "k3s-bastion" }
}

output "k3s-bastion_public_ip" {
  value = aws_instance.k3s-bastion.public_ip
}
output "k3s-bastion_private_ip" {
  value = aws_instance.k3s-bastion.private_ip
}
