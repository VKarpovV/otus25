#!/bin/bash

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Install Apache
sudo apt-get install -y apache2
sudo systemctl enable apache2

# Configure Apache
sudo cp /home/kva/otus25/configs/apache/apache2.conf /etc/apache2/apache2.conf
sudo cp /home/kva/otus25/configs/apache/sites-available/* /etc/apache2/sites-available/
sudo a2ensite default
sudo a2enmod rewrite

# Install MySQL Slave
/home/kva/otus25/scripts/mysql_slave_setup.sh

# Install Prometheus
/home/kva/otus25/scripts/prometheus_setup.sh

# Install Grafana
/home/kva/otus25/scripts/grafana_setup.sh

# Install FileBeat
sudo dpkg -i /home/kva/elk-8.9-deb/filebeat-8.9.1-amd64.deb
sudo cp /home/kva/otus25/configs/elk/filebeat.yml /etc/filebeat/filebeat.yml
sudo systemctl enable filebeat
sudo systemctl start filebeat

# Install ELK stack
/home/kva/otus25/scripts/elk_setup.sh

# Restart Apache
sudo systemctl restart apache2

echo "VM3 setup completed!"
