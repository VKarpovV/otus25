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

# Установка Apache2
./scripts/apache_setup.sh 2

# Установка ELK
./scripts/elk_setup.sh

# Установка Filebeat
./scripts/filebeat_setup.sh

echo "Установка на VM3 завершена!"
