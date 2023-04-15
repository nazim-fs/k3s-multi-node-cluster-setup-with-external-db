variable "private_subnet_id" {}
variable "k3s_db_private_ip" {}
variable "ami_id" {}
variable "key_name" {}
variable "k3s_master_nodes_token" {}

resource "aws_instance" "k3s-master-1" {
  ami                         = var.ami_id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  user_data                   = data.template_file.master_1_user_data.rendered
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.k3s-master-sg.id]
  tags                        = { Name = "k3s-master-1" }
}

resource "aws_instance" "k3s-master-2" {
  ami                         = var.ami_id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  user_data                   = data.template_file.master_2_user_data.rendered
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.k3s-master-sg.id]
  tags                        = { Name = "k3s-master-2" }
  depends_on                  = [aws_instance.k3s-master-1]
}

data "template_file" "master_1_user_data" {
  template = file("scripts/master_1_init.sh")

  vars = {
    k3s_master_nodes_token = var.k3s_master_nodes_token,
    k3s_db_private_ip      = var.k3s_db_private_ip
  }
}

data "template_file" "master_2_user_data" {
  template = file("scripts/master_2_init.sh")

  vars = {
    k3s_master_nodes_token = var.k3s_master_nodes_token,
    k3s_db_private_ip      = var.k3s_db_private_ip
  }
}

output "k3s-master-1_private_ip" {
  value = aws_instance.k3s-master-1.private_ip
}

output "k3s-master-2_private_ip" {
  value = aws_instance.k3s-master-2.private_ip
}
