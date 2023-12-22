#!/bin/bash

# Disable swap
sudo swapoff -a

sudo sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab

# Load kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Kernel paremeters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# General dependencies
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
