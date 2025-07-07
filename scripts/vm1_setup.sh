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
sudo cp /home/kva/otus25/configs/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp /home/kva/otus25/configs/nginx/sites-available/* /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Install FileBeat
sudo dpkg -i /home/kva/elk-8.9-deb/filebeat-8.9.1-amd64.deb
sudo cp /home/kva/otus25/configs/elk/filebeat.yml /etc/filebeat/filebeat.yml
sudo systemctl enable filebeat
sudo systemctl start filebeat

# Install ELK stack
/home/kva/otus25/scripts/elk_setup.sh

# Restart NGINX
sudo systemctl restart nginx

echo "VM1 setup completed!"
