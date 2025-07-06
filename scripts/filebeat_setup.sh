#!/bin/bash

# Установка Filebeat
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.4.3-amd64.deb
sudo dpkg -i filebeat-8.4.3-amd64.deb

# Настройка Filebeat
sudo cp configs/filebeat/filebeat.yml /etc/filebeat/
sudo filebeat modules enable system nginx apache mysql

# Запуск Filebeat
sudo systemctl start filebeat
sudo systemctl enable filebeat

echo "Filebeat установлен и настроен"
