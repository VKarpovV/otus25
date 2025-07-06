#!/bin/bash

if [ -z "$1" ]; then
    echo "Не указан номер сервера (1 или 2)"
    exit 1
fi

SERVER_NUM=$1

# Установка Apache
sudo apt install -y apache2

# Настройка Apache
sudo cp configs/apache/apache$SERVER_NUM.conf /etc/apache2/sites-available/000-default.conf
sudo cp configs/apache/ports.conf /etc/apache2/

# Включение модулей
sudo a2enmod rewrite proxy proxy_http

# Перезапуск Apache
sudo systemctl restart apache2
sudo systemctl enable apache2

# Установка Filebeat для Apache
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.4.3-amd64.deb
sudo dpkg -i filebeat-8.4.3-amd64.deb
sudo cp configs/filebeat/filebeat-apache.yml /etc/filebeat/filebeat.yml
sudo systemctl start filebeat
sudo systemctl enable filebeat

echo "Apache$SERVER_NUM установлен и настроен"
