#!/bin/bash

# Запуск MySQL Master в Docker
docker-compose -f docker-compose/mysql-compose.yml up -d mysql_master

# Ожидание запуска MySQL
sleep 30

# Настройка репликации
docker exec mysql_master mysql -uroot -prootpassword -e "
CREATE USER 'replica'@'%' IDENTIFIED WITH mysql_native_password BY 'replica_password';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;
SHOW MASTER STATUS;
"

# Копирование конфигурации
docker cp mysql_master:/etc/mysql/my.cnf configs/mysql/my-master.cnf

echo "MySQL Master настроен"
