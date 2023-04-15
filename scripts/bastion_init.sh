#!/bin/bash
set -ex

# Set the hostname
sudo hostnamectl set-hostname k3s-bastion
sudo sed -i '/- update_etc_hosts/d' /etc/cloud/cloud.cfg
echo k3s-bastion | sudo tee /etc/hostname
sudo systemctl restart systemd-hostnamed
sudo tee -a /etc/hosts > /dev/null <<EOT
127.0.1.1	 k3s-bastion
EOT

# Install essential packages
sudo apt-get update > /dev/null && sudo apt-get install -y git curl telnet > /dev/null

# Add Entries in /etc/hosts
sudo tee -a /etc/hosts > /dev/null <<EOT
${k3s_master_1_private_ip} k3s-master-1
${k3s_master_2_private_ip} k3s-master-2
${k3s_worker_1_private_ip} k3s-worker-1
${k3s_worker_2_private_ip} k3s-worker-2
${k3s_lb_private_ip}       k3s-lb
${k3s_db_private_ip}       k3s-db
${k3s_bastion_private_ip}  k3s-bastion
EOT

# Install and setup kubectl utility
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Copy the kubeconfig file onto bastion host
mkdir -p .kube && scp -o StrictHostKeyChecking=no ${k3s_master_1_private_ip}:/home/admin/.kube/config .kube/

# Replace the local IP in kubeconfig with load balancer's IP
sed -i "s/127.0.0.1/${k3s_lb_private_ip}/g" /home/admin/.kube/config
