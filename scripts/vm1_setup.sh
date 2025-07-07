#!/bin/bash

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Install NGINX
sudo apt-get install -y nginx
sudo systemctl enable nginx

# Configure NGINX
sudo mkdir -p /etc/nginx/sites-available
sudo cp /home/kva/otus25/configs/nginx/nginx.conf /etc/nginx/
sudo cp /home/kva/otus25/configs/nginx/default /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Install FileBeat
sudo dpkg -i /home/kva/elk-8.9-deb/filebeat-8.9.1-amd64.deb
sudo mkdir -p /etc/filebeat
sudo cp /home/kva/otus25/configs/elk/filebeat/filebeat.yml /etc/filebeat/
sudo chown root:root /etc/filebeat/filebeat.yml
sudo chmod 640 /etc/filebeat/filebeat.yml
sudo systemctl enable filebeat
sudo systemctl start filebeat

# Install ELK stack
bash /home/kva/otus25/scripts/elk_setup.sh

# Restart NGINX
sudo systemctl restart nginx

echo "VM1 setup completed!"
