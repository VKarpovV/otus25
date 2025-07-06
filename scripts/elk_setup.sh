#!/bin/bash

# Увеличение vm.max_map_count
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Запуск ELK стека
docker-compose -f docker-compose/elk-compose.yml up -d

# Ожидание запуска Elasticsearch
sleep 60

# Настройка индексов в Elasticsearch
curl -X PUT "http://localhost:9200/_index_template/filebeat" \
  -H "Content-Type: application/json" \
  --data-binary @configs/elk/filebeat-index-template.json

echo "ELK стек установлен и настроен"
