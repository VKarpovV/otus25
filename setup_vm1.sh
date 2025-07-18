#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Настройка репликации MySQL Master
sudo mkdir -p /etc/mysql/conf.d
echo "[mysqld]
server-id = 1
log_bin = mysql-bin
binlog_format = ROW
binlog_do_db = mydb" | sudo tee /etc/mysql/conf.d/replication.cnf

# Разрешение подключений к MySQL
sudo ufw allow from 192.168.140.0/24 to any port 3306

# Клонирование репозитория
sudo rm -rf otus25
git clone https://github.com/VKarpovV/otus25.git
cd otus25

# Запуск сервисов для VM1
sudo docker compose up -d nginx apache1 mysql_master

# Ожидание запуска MySQL
echo "Ожидание запуска MySQL Master (20 секунд)..."
sleep 20

# Кастомизация Apache1
sudo docker exec otus25-apache1-1 bash -c "echo 'This is Apache1 on VM1' > /usr/local/apache2/htdocs/index.html"

# Экспорта метрик Apache
echo "Настройка Apache для экспорта метрик..."
sudo docker exec otus25-apache1-1 bash -c "echo 'LoadModule status_module modules/mod_status.so' >> /usr/local/apache2/conf/httpd.conf"
sudo docker exec otus25-apache1-1 bash -c "echo '<Location /server-status>' >> /usr/local/apache2/conf/httpd.conf"
sudo docker exec otus25-apache1-1 bash -c "echo '    SetHandler server-status' >> /usr/local/apache2/conf/httpd.conf"
sudo docker exec otus25-apache1-1 bash -c "echo '    Require all granted' >> /usr/local/apache2/conf/httpd.conf"
sudo docker exec otus25-apache1-1 bash -c "echo '</Location>' >> /usr/local/apache2/conf/httpd.conf"
sudo docker exec otus25-apache1-1 bash -c "echo 'ExtendedStatus On' >> /usr/local/apache2/conf/httpd.conf"
sudo docker exec otus25-apache1-1 apachectl restart


# Настройка Nginx для экспорта метрик
echo "Настройка Nginx для экспорта метрик..."
sudo docker exec otus25-nginx-1 bash -c "echo 'server {' > /etc/nginx/conf.d/stub_status.conf"
sudo docker exec otus25-nginx-1 bash -c "echo '    listen 80;' >> /etc/nginx/conf.d/stub_status.conf"
sudo docker exec otus25-nginx-1 bash -c "echo '    location /stub_status {' >> /etc/nginx/conf.d/stub_status.conf"
sudo docker exec otus25-nginx-1 bash -c "echo '        stub_status;' >> /etc/nginx/conf.d/stub_status.conf"
sudo docker exec otus25-nginx-1 bash -c "echo '        allow all;' >> /etc/nginx/conf.d/stub_status.conf"
sudo docker exec otus25-nginx-1 bash -c "echo '    }' >> /etc/nginx/conf.d/stub_status.conf"
sudo docker exec otus25-nginx-1 bash -c "echo '}' >> /etc/nginx/conf.d/stub_status.conf"
sudo docker exec otus25-nginx-1 nginx -s reload

# Запуск экспортеров
echo "Запуск экспортеров метрик..."
sudo docker compose up -d node-exporter cadvisor apache-exporter mysql-exporter nginx-exporter


echo "Проверка работы экспортеров:"
echo "Node exporter:    curl http://localhost:9100/metrics"
echo "cAdvisor:         curl http://localhost:8080/metrics"
echo "Apache exporter:  curl http://localhost:9117/metrics"
echo "MySQL exporter:   curl http://localhost:9104/metrics"
echo "Nginx exporter:   curl http://localhost:9113/metrics"

# Получаем полное имя контейнера
MYSQL_CONTAINER=$(sudo docker ps --filter "name=mysql_master" --format "{{.Names}}")

if [ -z "$MYSQL_CONTAINER" ]; then
    echo "ОШИБКА: Контейнер mysql_master не найден"
    echo "Список контейнеров:"
    sudo docker ps -a
    echo "Логи:"
    sudo docker logs $(sudo docker ps -aqf "name=mysql_master")
    exit 1
fi

# Настройка репликации
sudo docker exec mysql_master mysql -uroot -proot_password -e "
ALTER USER 'repl_user'@'%' IDENTIFIED WITH mysql_native_password BY 'repl_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;"

# Получение статуса мастера
MASTER_STATUS=$(sudo docker exec mysql_master mysql -uroot -proot_password -e "SHOW MASTER STATUS\G")
echo "========================================"
echo "MASTER STATUS:"
echo "$MASTER_STATUS"
echo "========================================"
echo "Сохраните значения File и Position для VM2"
echo "Пример:"
echo "MASTER_LOG_FILE: mysql-bin.000001"
echo "MASTER_LOG_POS: 157"

echo "Запуск экспортеров мониторинга..."

# Node Exporter
sudo docker run -d --name node_exporter --net=host \
  -v /:/host:ro,rslave \
  prom/node-exporter:latest \
  --path.rootfs=/host \
  --web.listen-address=0.0.0.0:9100

# Apache Exporter
sudo docker run -d --name apache_exporter --net=host \
  lusotycoon/apache-exporter:latest \
  --scrape_uri=http://localhost:80/server-status?auto \
  --port=9117 \
  --insecure

# MySQL Exporter
sudo docker run -d --name mysql_exporter --net=host \
  -e DATA_SOURCE_NAME="exporter:exporterpassword@(localhost:3306)/" \
  prom/mysqld-exporter:latest \
  --web.listen-address=0.0.0.0:9104

# Nginx Exporter
sudo docker run -d --name nginx_exporter --net=host \
  nginx/nginx-prometheus-exporter:latest \
  -nginx.scrape-uri=http://localhost:80/stub_status \
  -web.listen-address=0.0.0.0:9113

echo "Проверка работы экспортеров..."
sleep 10  # Даем время для запуска

echo "Node Exporter:"
curl -s http://localhost:9100/metrics | head -5
echo "Apache Exporter:"
curl -s http://localhost:9117/metrics | head -5
echo "MySQL Exporter:"
curl -s http://localhost:9104/metrics | head -5
echo "Nginx Exporter:"
curl -s http://localhost:9113/metrics | head -5
