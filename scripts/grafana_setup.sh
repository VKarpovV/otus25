#!/bin/bash

# Запуск Grafana в Docker
docker-compose -f docker-compose/monitoring-compose.yml up -d grafana

# Ожидание запуска Grafana
sleep 30

# Настройка источника данных Prometheus
curl -X POST "http://localhost:3000/api/datasources" \
  -u admin:admin \
  -H "Content-Type: application/json" \
  --data-binary @configs/grafana/prometheus-datasource.json

# Импорт дашбордов
for dashboard in configs/grafana/dashboards/*.json; do
  curl -X POST "http://localhost:3000/api/dashboards/db" \
    -u admin:admin \
    -H "Content-Type: application/json" \
    --data-binary @"$dashboard"
done

echo "Grafana установлена и настроена"
