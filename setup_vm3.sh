#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Увеличение vm.max_map_count для Elasticsearch
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Клонирование репозитория
git clone https://github.com/VKarpovV/otus25.git
cd otus25

# Запуск сервисов для VM3
sudo docker compose up -d prometheus grafana elk

# Настройка Grafana
echo "Ожидание запуска Grafana (30 секунд)..."
sleep 30
sudo docker exec grafana grafana-cli plugins install grafana-piechart-panel
sudo docker exec grafana grafana-cli plugins install alexanderzobnin-zabbix-app
sudo docker restart grafana

# Создание источника данных Prometheus
curl -X POST "http://admin:admin@localhost:3000/api/datasources" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }'
  
# Импорт стандартных дашбордов
echo "Импорт дашбордов в Grafana..."

# Node Exporter Dashboard
curl -X POST "http://admin:admin@localhost:3000/api/dashboards/db" \
  -H "Content-Type: application/json" \
  -d '{
    "dashboard": {
      "id": null,
      "uid": null,
      "title": "Node Exporter",
      "timezone": "browser",
      "schemaVersion": 16,
      "version": 0,
      "refresh": "30s"
    },
    "folderId": 0,
    "overwrite": false
  }'

echo "Дашборды успешно импортированы"  
  
echo "Настройка завершена на VM3"
echo "Доступ к сервисам:"
echo "- Prometheus: http://192.168.140.134:9090"
echo "- Grafana: http://192.168.140.134:3000 (admin/admin)"
echo "- Kibana: http://192.168.140.134:5601"

echo "Запуск экспортеров мониторинга..."

# Node Exporter
sudo docker run -d --name node_exporter --net=host \
  -v /:/host:ro,rslave \
  prom/node-exporter:latest \
  --path.rootfs=/host \
  --web.listen-address=0.0.0.0:9100

echo "Проверка работы экспортеров..."
sleep 10  # Даем время для запуска

echo "Node Exporter:"
curl -s http://localhost:9100/metrics | head -5
