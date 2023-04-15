variable "private_subnet_id" {}
variable "k3s_master_1_private_ip" {}
variable "k3s_master_2_private_ip" {}
variable "ami_id" {}
variable "key_name" {}

resource "aws_instance" "k3s-lb" {
  ami                         = var.ami_id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  private_ip                  = "10.0.1.10"
  user_data                   = data.template_file.lb_user_data.rendered
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.k3s-lb-sg.id]
  tags                        = { Name = "k3s-lb" }
}

data "template_file" "lb_user_data" {
  template = file("scripts/lb_init.sh")

  vars = {
    k3s_master_1_private_ip = var.k3s_master_1_private_ip,
    k3s_master_2_private_ip = var.k3s_master_2_private_ip
  }
}

output "k3s-lb_private_ip" {
  value = aws_instance.k3s-lb.private_ip
}
