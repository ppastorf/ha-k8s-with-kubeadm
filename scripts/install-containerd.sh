#!/bin/bash

# Add the Docker package repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Install containerd
sudo apt update; sudo apt install -y containerd.io

# Configure
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i '/SystemdCgroup/ s/false/true/' /etc/containerd/config.toml
sudo sed -i '/disabled_plugins/ s/\"cri\"//' /etc/containerd/config.toml

# Restart service
sudo systemctl restart containerd
