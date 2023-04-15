resource "random_uuid" "master_node_token" {}

# AMIs
data "aws_ami" "debian_amd64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"]
}

# Retrieve the public IP
data "http" "public_ip" {
  url = "https://ifconfig.me/ip"
}

resource "aws_key_pair" "nodes_key_pair" {
  key_name   = "k3s-nodes-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjmEgZzzSaPXVAy65cFvvwhWORG736+WUtlJUzLZ1IvA2vuGzLpEoplJHBGlHY03n/YhCAv23HzlXMvsdbvwobvwm="
}
