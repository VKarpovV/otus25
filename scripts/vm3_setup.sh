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
sudo mkdir -p /etc/apache2/sites-available
sudo cp /home/kva/otus25/configs/apache/apache2.conf /etc/apache2/
sudo cp /home/kva/otus25/configs/apache/default /etc/apache2/sites-available/
sudo a2ensite default
sudo a2enmod rewrite

# Install MySQL Slave
bash /home/kva/otus25/scripts/mysql_slave_setup.sh

# Install Prometheus
bash /home/kva/otus25/scripts/prometheus_setup.sh

# Install Grafana
bash /home/kva/otus25/scripts/grafana_setup.sh

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

# Restart Apache
sudo systemctl restart apache2

echo "VM3 setup completed!"
