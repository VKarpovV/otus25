#!/bin/bash

# Install MySQL 8
sudo apt-get install -y mysql-server

# Configure MySQL Slave
sudo cp /home/kva/otus25/configs/mysql/slave.cnf /etc/mysql/mysql.conf.d/replication.cnf
sudo systemctl restart mysql

# Configure replication
MASTER_LOG_FILE=$(grep "File" /home/kva/mysql_master_status.txt | awk '{print $2}')
MASTER_LOG_POS=$(grep "Position" /home/kva/mysql_master_status.txt | awk '{print $2}')

sudo mysql -e "CHANGE MASTER TO MASTER_HOST='192.168.140.133', MASTER_USER='replicator', MASTER_PASSWORD='replicator_password', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS;"
sudo mysql -e "START SLAVE;"

echo "MySQL Slave setup completed!"
