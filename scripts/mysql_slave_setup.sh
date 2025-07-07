#!/bin/bash

# Запуск MySQL Slave в Docker
docker-compose -f docker-compose/mysql-compose.yml up -d mysql_slave

# Ожидание запуска MySQL
sleep 30

# Получение позиции репликации с мастера
MASTER_STATUS=$(ssh kva@192.168.140.132 "docker exec mysql_master mysql -uroot -prootpassword -e 'SHOW MASTER STATUS\G'")

MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | awk '/File:/ {print $2}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | awk '/Position:/ {print $2}')

# Настройка репликации на славе
docker exec mysql_slave mysql -uroot -prootpassword -e "
CHANGE MASTER TO
MASTER_HOST='192.168.140.132',
MASTER_USER='replica',
MASTER_PASSWORD='replica_password',
MASTER_LOG_FILE='$MASTER_LOG_FILE',
MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
"

echo "MySQL Slave настроен"
