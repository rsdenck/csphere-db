#!/usr/bin/env bash
set -euo pipefail

# Run INSIDE the LXC container to set up MySQL for csphere-db

echo "=== Installing MySQL ==="
apt-get update -qq
apt-get install -y -qq mysql-server mysql-client

echo "=== Configuring MySQL ==="
mysql -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'csphere-admin';
CREATE USER IF NOT EXISTS 'csphere'@'%' IDENTIFIED WITH mysql_native_password BY 'csphere-pass';
GRANT ALL PRIVILEGES ON csphere.* TO 'csphere'@'%';
FLUSH PRIVILEGES;
SQL

sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

echo "=== Importing schema ==="
mysql -u root -pcsphere-admin < /tmp/schema.sql

echo "=== Done ==="
echo "MySQL is running and schema imported"
