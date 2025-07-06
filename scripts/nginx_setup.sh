#!/bin/bash

# Установка NGINX
sudo apt install -y nginx

# Копирование конфигурационных файлов
sudo cp configs/nginx/nginx.conf /etc/nginx/
sudo cp configs/nginx/sites-available/* /etc/nginx/sites-available/

# Создание символических ссылок
sudo ln -s /etc/nginx/sites-available/backend1 /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/backend2 /etc/nginx/sites-enabled/

# Настройка балансировки нагрузки
sudo cp configs/nginx/load_balancer.conf /etc/nginx/conf.d/

# Перезапуск NGINX
sudo systemctl restart nginx
sudo systemctl enable nginx

# Установка Filebeat для NGINX
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.4.3-amd64.deb
sudo dpkg -i filebeat-8.4.3-amd64.deb
sudo cp configs/filebeat/filebeat.yml /etc/filebeat/
sudo systemctl start filebeat
sudo systemctl enable filebeat

echo "NGINX установлен и настроен"
