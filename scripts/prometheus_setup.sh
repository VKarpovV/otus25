#!/bin/bash

# Create prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Create directories
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Download and install Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-amd64.tar.gz
tar xvf prometheus-2.30.3.linux-amd64.tar.gz
sudo cp prometheus-2.30.3.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.30.3.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-2.30.3.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.30.3.linux-amd64/console_libraries /etc/prometheus

# Configure Prometheus
sudo cp /home/kva/otus25/configs/prometheus/prometheus.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Create systemd service
sudo cp /home/kva/otus25/configs/prometheus/prometheus.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

echo "Prometheus setup completed!"
