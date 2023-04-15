#!/bin/bash
set -ex

# Set the hostname
sudo hostnamectl set-hostname k3s-db
sudo sed -i '/- update_etc_hosts/d' /etc/cloud/cloud.cfg
echo k3s-db | sudo tee /etc/hostname
sudo systemctl restart systemd-hostnamed
sudo tee -a /etc/hosts > /dev/null <<EOT
127.0.1.1	 k3s-db
EOT

# Install essential packages
sudo apt-get update && sudo apt-get install -y git curl telnet

# Install ETCD as DB
sudo apt-get install -y etcd

# Configure ETCD as external DB
k3s_db_private_ip="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
sudo cp /etc/default/etcd /etc/default/etcd.bkp
etcd_file="/etc/default/etcd"
ETCD_CONFIG_LINES=("ETCD_LISTEN_PEER_URLS=\"http://$k3s_db_private_ip:2380\"" "ETCD_LISTEN_CLIENT_URLS=\"http://$k3s_db_private_ip:2379\"" "ETCD_ADVERTISE_CLIENT_URLS=\"http://$k3s_db_private_ip:2379\"")
for config in "$${ETCD_CONFIG_LINES[@]}"; do
  if ! (cat "$etcd_file" | grep -i "$config"); then
    echo "$config" >> "$etcd_file"
  fi
done

# Restart ETCD and enable it for reboot
sudo systemctl restart etcd.service
sudo systemctl enable etcd.service
