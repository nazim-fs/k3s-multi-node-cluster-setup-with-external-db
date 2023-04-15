#!/bin/bash
set -ex

# Set the hostname
sudo hostnamectl set-hostname k3s-lb
sudo sed -i '/- update_etc_hosts/d' /etc/cloud/cloud.cfg
echo k3s-lb | sudo tee /etc/hostname
sudo systemctl restart systemd-hostnamed
sudo tee -a /etc/hosts > /dev/null <<EOT
127.0.1.1	 k3s-lb
EOT

# Install essential packages
sudo apt-get update && sudo apt-get install -y git curl telnet

# Install HAproxy
sudo apt-get install -y haproxy

# Configure HAproxy
k3s_lb_private_ip="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bkp
sudo sed -i "s/\(.*mode.*\)\(http\)\(.*\)/\1tcp\3/" /etc/haproxy/haproxy.cfg
sudo tee -a /etc/haproxy/haproxy.cfg > /dev/null <<EOT
frontend k3s-load-balancer
   bind $k3s_lb_private_ip:6443
   stats uri /haproxy?stats
   default_backend k3s-master-nodes

backend k3s-master-nodes
    balance roundrobin
    server k3s-master-1 ${k3s_master_1_private_ip}:6443
    server k3s-master-2 ${k3s_master_2_private_ip}:6443

listen stats
   bind *:6443
   stats enable
   stats uri /
   stats refresh 5s
   stats realm Haproxy\ Statistics
EOT

# Restart HAproxy and enable it for reboot
sudo systemctl restart haproxy.service
sudo systemctl enable haproxy.service
