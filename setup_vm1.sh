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
git clone https://github.com/VKarpovV/otus25.git
cd otus25

# Запуск сервисов для VM1
sudo docker compose up -d nginx apache1 mysql_master

# Ожидание запуска MySQL
echo "Ожидание запуска MySQL Master (40 секунд)..."
sleep 40

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
MASTER_STATUS=$(sudo docker exec mysql_master mysql -uroot -proot_password -e "SHOW MASTER STATUS" 2>/dev/null)
echo "========================================"
echo "MASTER STATUS:"
echo "$MASTER_STATUS"
echo "========================================"
echo "Сохраните значения File и Position для VM2"
echo "Пример:"
echo "MASTER_LOG_FILE: mysql-bin.000001"
echo "MASTER_LOG_POS: 157"
