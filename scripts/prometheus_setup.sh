#!/bin/bash

# Создание директории для конфигов
mkdir -p /home/kva/prometheus/config
cp configs/prometheus/prometheus.yml /home/kva/prometheus/config/

# Запуск Prometheus в Docker
docker-compose -f docker-compose/monitoring-compose.yml up -d prometheus

echo "Prometheus установлен и настроен"
