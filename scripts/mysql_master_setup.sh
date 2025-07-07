#!/bin/bash

# Install MySQL 8
sudo apt-get install -y mysql-server

# Configure MySQL Master
sudo cp /home/kva/otus25/configs/mysql/master.cnf /etc/mysql/mysql.conf.d/replication.cnf
sudo systemctl restart mysql

# Create replication user
sudo mysql -e "CREATE USER 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'replicator_password';"
sudo mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Get master status
sudo mysql -e "SHOW MASTER STATUS;" > /home/kva/mysql_master_status.txt

echo "MySQL Master setup completed!"
