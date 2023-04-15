#!/bin/bash
set -ex

# Set the hostname
sudo hostnamectl set-hostname k3s-master-1
sudo sed -i '/- update_etc_hosts/d' /etc/cloud/cloud.cfg
echo k3s-master-1 | sudo tee /etc/hostname
sudo systemctl restart systemd-hostnamed
sudo tee -a /etc/hosts > /dev/null <<EOT
127.0.1.1	 k3s-master-1
EOT

# Install essential packages
sudo apt-get update && sudo apt-get install -y git curl telnet

# Configure k3s master nodes
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san 10.0.1.10" INSTALL_K3S_VERSION=v1.26.3+k3s1 sh -s - server --token=${k3s_master_nodes_token} --datastore-endpoint="http://${k3s_db_private_ip}:2379" --node-taint node-role.kubernetes.io/master:NoSchedule --write-kubeconfig-mode 644

mkdir /home/admin/.kube
cp /etc/rancher/k3s/k3s.yaml /home/admin/.kube/config
chown admin:admin /home/admin/.kube -R
chmod 700 /home/admin/.kube
chmod 600 /home/admin/.kube/config

# Enable k3s service
sudo systemctl enable k3s.service
