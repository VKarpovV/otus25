#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Настройка репликации MySQL Slave
sudo mkdir -p /etc/mysql/conf.d
echo "[mysqld]
server-id = 2
log_bin = mysql-bin
binlog_format = ROW
relay-log = mysql-relay-bin
log-slave-updates = 1
read-only = 1" | sudo tee /etc/mysql/conf.d/replication.cnf

# Клонирование репозитория
git clone https://github.com/VKarpovV/otus25.git
cd otus25

# Запуск сервисов для VM2
sudo docker compose up -d apache2 mysql_slave

# Ожидание запуска MySQL
echo "Ожидание запуска MySQL Slave (40 секунд)..."
sleep 40

# Проверка контейнера
if ! sudo docker ps | grep -q "mysql_slave"; then
    echo "ОШИБКА: Контейнер mysql_slave не запущен"
    sudo docker logs mysql_slave
    exit 1
fi

# Получаем полное имя контейнера
MYSQL_CONTAINER=$(sudo docker ps --filter "name=mysql_slave" --format "{{.Names}}")

if [ -z "$MYSQL_CONTAINER" ]; then
    echo "ОШИБКА: Контейнер mysql_slave не найден"
    echo "Список контейнеров:"
    sudo docker ps -a
    echo "Логи:"
    sudo docker logs $(sudo docker ps -aqf "name=mysql_slave")
    exit 1
fi

# Получение данных репликации
read -p "Введите MASTER_LOG_FILE (из вывода VM1): " MASTER_LOG_FILE
read -p "Введите MASTER_LOG_POS (из вывода VM1): " MASTER_LOG_POS

# Настройка репликации
sudo docker exec mysql_slave mysql -uroot -proot_password -e "
STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO
MASTER_HOST='192.168.140.132',
MASTER_USER='repl_user',
MASTER_PASSWORD='repl_password',
MASTER_LOG_FILE='$MASTER_LOG_FILE',
MASTER_LOG_POS=$MASTER_LOG_POS,
MASTER_CONNECT_RETRY=10,
GET_MASTER_PUBLIC_KEY=1;
START SLAVE;"

# Проверка статуса репликации
sleep 5
echo "Проверка соединения с Master:"
sudo docker exec mysql_slave mysql -h 192.168.140.132 -u repl_user -prepl_password -e "SELECT 1;"

echo "Статус репликации:"
sudo docker exec mysql_slave mysql -uroot -proot_password -e "SHOW SLAVE STATUS\G" | grep -E 'Running|Error'
echo "========================================"
echo "SLAVE STATUS:"
echo "$SLAVE_STATUS" | grep -E "Slave_IO_Running|Slave_SQL_Running|Last_IO_Error|Last_SQL_Error"
echo "========================================"
echo "Убедитесь, что:"
echo "Slave_IO_Running: Yes"
echo "Slave_SQL_Running: Yes"

echo "Запуск экспортеров мониторинга..."

# Node Exporter
sudo docker run -d --name node_exporter --net=host \
  -v /:/host:ro,rslave \
  prom/node-exporter:latest \
  --path.rootfs=/host \
  --web.listen-address=0.0.0.0:9100

# cAdvisor
sudo docker run -d --name cadvisor --net=host \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:ro \
  -v /sys:/sys:ro \
  -v /var/lib/docker/:/var/lib/docker:ro \
  -v /dev/disk/:/dev/disk:ro \
  --privileged \
  gcr.io/cadvisor/cadvisor:latest \
  --http_server_ip=0.0.0.0 \
  --port=8080

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

echo "Проверка работы экспортеров..."
sleep 10  # Даем время для запуска

echo "Node Exporter:"
curl -s http://localhost:9100/metrics | head -5
echo "Apache Exporter:"
curl -s http://localhost:9117/metrics | head -5
echo "MySQL Exporter:"
curl -s http://localhost:9104/metrics | head -5
echo "cAdvisor:"
curl -s http://localhost:8080/metrics | head -5

