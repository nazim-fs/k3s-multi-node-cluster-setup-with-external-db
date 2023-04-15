#!/bin/bash
set -ex

# Set the hostname
sudo hostnamectl set-hostname k3s-worker-1
sudo sed -i '/- update_etc_hosts/d' /etc/cloud/cloud.cfg
echo k3s-worker-1 | sudo tee /etc/hostname
sudo systemctl restart systemd-hostnamed
sudo tee -a /etc/hosts > /dev/null <<EOT
127.0.1.1	 k3s-worker-1
EOT

# Install essential packages
sudo apt-get update && sudo apt-get install -y git curl telnet

# Configure k3s worker nodes
curl -sfL https://get.k3s.io | K3S_URL=https://${k3s_lb_private_ip}:6443 K3S_TOKEN=${k3s_master_nodes_token} INSTALL_K3S_VERSION=v1.26.3+k3s1 sh -

# Enable k3s-agent service
sudo systemctl enable k3s-agent.service
