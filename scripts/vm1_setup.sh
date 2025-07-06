#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
sudo apt install -y docker.io docker-compose git

# Добавление пользователя kva в группу docker
sudo usermod -aG docker kva

# Клонирование репозитория
git clone https://github.com/VKarpovV/otus25.git
cd otus25

# Установка NGINX
./scripts/nginx_setup.sh

# Установка MySQL Master
./scripts/mysql_master_setup.sh

# Установка Prometheus
./scripts/prometheus_setup.sh

echo "Установка на VM1 завершена!"
