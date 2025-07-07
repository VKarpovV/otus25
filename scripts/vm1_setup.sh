#!/bin/bash

# Установка Docker (если ещё не установлен)
./scripts/setup_docker.sh

# Настройка NGINX
./scripts/nginx_setup.sh

# Настройка MySQL Master
./scripts/mysql_master_setup.sh

# Запуск Prometheus
docker-compose -f ./docker-compose/prometheus.yml up -d

echo "✅ VM1 настроена!"
