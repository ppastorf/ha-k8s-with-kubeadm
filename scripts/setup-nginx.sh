#!/bin/bash

# Install nginx
sudo apt update
sudo apt install -y nginx
sudo apt-mark hold nginx

# Usually this module has to be installed for our config to work
sudo apt install -y libnginx-mod-stream

# Enable it as a systemd service
sudo systemctl enable --now nginx

# Create the directory for tcp configs
sudo mkdir -p /etc/nginx/tcpconf.d/

# Reference the directory in the main config
sudo echo "include /etc/nginx/tcpconf.d/*;" >> /etc/nginx/nginx.conf
