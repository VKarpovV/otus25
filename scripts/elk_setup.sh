#!/bin/bash

# Install Elasticsearch
sudo dpkg -i /home/kva/elk-8.9-deb/elasticsearch-8.9.1-amd64.deb
sudo cp /home/kva/otus25/configs/elk/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# Install Logstash
sudo dpkg -i /home/kva/elk-8.9-deb/logstash-8.9.1-amd64.deb
sudo cp /home/kva/otus25/configs/elk/logstash.conf /etc/logstash/conf.d/
sudo systemctl enable logstash
sudo systemctl start logstash

# Install Kibana
sudo dpkg -i /home/kva/elk-8.9-deb/kibana-8.9.1-amd64.deb
sudo cp /home/kva/otus25/configs/elk/kibana.yml /etc/kibana/
sudo systemctl enable kibana
sudo systemctl start kibana

echo "ELK stack setup completed!"
