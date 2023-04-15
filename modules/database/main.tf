variable "private_subnet_id" {}
variable "ami_id" {}
variable "key_name" {}

resource "aws_instance" "k3s-db" {
  ami                         = var.ami_id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  user_data                   = data.template_file.db_user_data.rendered
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.k3s-db-sg.id]
  tags                        = { Name = "k3s-db" }
}

data "template_file" "db_user_data" {
  template = file("scripts/db_init.sh")
}

output "k3s-db_private_ip" {
  value = aws_instance.k3s-db.private_ip
}
