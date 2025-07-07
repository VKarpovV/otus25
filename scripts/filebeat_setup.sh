#!/bin/bash

# Установка Filebeat
sudo dpkg -i /home/kva/elk-8.9-deb/filebeat-8.9.1-amd64.deb

# Определение типа сервера и копирование соответствующего конфига
if [ -f "/etc/nginx/nginx.conf" ]; then
  # Это NGINX сервер
  CONFIG_FILE="nginx-filebeat.yml"
elif [ -f "/etc/apache2/apache2.conf" ]; then
  # Это Apache сервер
  CONFIG_FILE="apache-filebeat.yml"
else
  # Базовый конфиг
  CONFIG_FILE="filebeat.yml"
fi

sudo mkdir -p /etc/filebeat
sudo cp "/home/kva/otus25/configs/elk/filebeat/${CONFIG_FILE}" /etc/filebeat/filebeat.yml
sudo chown root:root /etc/filebeat/filebeat.yml
sudo chmod 640 /etc/filebeat/filebeat.yml

# Настройка модулей
sudo filebeat modules enable system
sudo filebeat setup

# Запуск Filebeat
sudo systemctl enable filebeat
sudo systemctl start filebeat

echo "Filebeat установлен и настроен с конфигом ${CONFIG_FILE}"
