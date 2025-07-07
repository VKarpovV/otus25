#!/bin/bash

# Установка Filebeat
sudo dpkg -i /home/kva/elk-8.9-deb/filebeat-8.9.1-amd64.deb

# Копирование конфига в зависимости от типа сервера
if [ -f "/etc/nginx/nginx.conf" ]; then
  # Это NGINX сервер
  sudo cp /home/kva/otus25/configs/elk/filebeat/nginx-filebeat.yml /etc/filebeat/filebeat.yml
elif [ -f "/etc/apache2/apache2.conf" ]; then
  # Это Apache сервер
  sudo cp /home/kva/otus25/configs/elk/filebeat/apache-filebeat.yml /etc/filebeat/filebeat.yml
else
  # Базовый конфиг
  sudo cp /home/kva/otus25/configs/elk/filebeat/filebeat.yml /etc/filebeat/filebeat.yml
fi

sudo chown root:filebeat /etc/filebeat/filebeat.yml
sudo chmod 640 /etc/filebeat/filebeat.yml

# Настройка модулей
sudo filebeat modules enable system
sudo filebeat setup

# Запуск Filebeat
sudo systemctl enable filebeat
sudo systemctl start filebeat

echo "Filebeat установлен и настроен!"
