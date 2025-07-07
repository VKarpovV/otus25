#!/bin/bash

# Установка NGINX
sudo apt-get install -y nginx

# Копирование конфига
sudo cp ./configs/nginx/nginx.conf /etc/nginx/nginx.conf

# Перезапуск NGINX
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "✅ NGINX настроен!"
