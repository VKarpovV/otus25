#!/bin/bash

# Install Grafana
wget https://dl.grafana.com/oss/release/grafana_8.1.5_amd64.deb
sudo apt-get install -y adduser libfontconfig1
sudo dpkg -i grafana_8.1.5_amd64.deb

# Configure Grafana
sudo cp /home/kva/otus25/configs/grafana/grafana.ini /etc/grafana/grafana.ini
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "Grafana setup completed!"
