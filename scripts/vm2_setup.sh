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

# Установка Apache1
./scripts/apache_setup.sh 1

# Установка MySQL Slave
./scripts/mysql_slave_setup.sh

# Установка Grafana
./scripts/grafana_setup.sh

echo "Установка на VM2 завершена!"
