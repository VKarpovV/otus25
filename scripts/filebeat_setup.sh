#!/bin/bash

# Install Filebeat
sudo dpkg -i /home/kva/elk-8.9-deb/filebeat-8.9.1-amd64.deb

# Configure Filebeat
sudo cp /home/kva/otus25/configs/elk/filebeat.yml /etc/filebeat/filebeat.yml
sudo filebeat modules enable system
sudo filebeat setup
sudo systemctl enable filebeat
sudo systemctl start filebeat

echo "Filebeat setup completed!"
