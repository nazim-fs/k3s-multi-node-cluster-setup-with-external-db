variable "k3s_master_1_private_ip" {}
variable "k3s_master_2_private_ip" {}
variable "k3s_worker_1_private_ip" {}
variable "k3s_worker_2_private_ip" {}
variable "k3s_lb_private_ip" {}
variable "k3s_db_private_ip" {}

resource "null_resource" "k3s_bastion" {
  depends_on = [aws_instance.k3s-bastion]
  #count      = length(aws_instance.k3s-master)

  # ssh into the k3s-master nodes
  connection {
    type        = "ssh"
    user        = "admin"
    private_key = file("id_rsa")
    port        = 22
    host        = aws_instance.k3s-bastion.public_ip
    timeout     = "1m"
  }

  # Provision the script using the template
  provisioner "file" {
    content = templatefile("scripts/bastion_init.sh", {
      k3s_master_1_private_ip = var.k3s_master_1_private_ip,
      k3s_master_2_private_ip = var.k3s_master_2_private_ip,
      k3s_worker_1_private_ip = var.k3s_worker_1_private_ip,
      k3s_worker_2_private_ip = var.k3s_worker_2_private_ip,
      k3s_lb_private_ip       = var.k3s_lb_private_ip,
      k3s_db_private_ip       = var.k3s_db_private_ip,
      k3s_bastion_private_ip  = aws_instance.k3s-bastion.private_ip
    })
    destination = "/home/admin/bastion_init.sh"
  }

  # Execute the script to setup bastion
  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/admin/bastion_init.sh /opt/bastion_init.sh",
      "chmod +x /opt/bastion_init.sh",
      "bash -x /opt/bastion_init.sh"
    ]
  }
}
