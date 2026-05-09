#!/usr/bin/env bash
set -euo pipefail

# Creates the LXC container for MySQL/csphere-db
CONTAINER=${1:-lxc-db}
IMAGE=${2:-ubuntu:22.04}

echo "=== Creating LXC container: $CONTAINER ==="
lxc init "$IMAGE" "$CONTAINER"

echo "=== Configuring resources ==="
lxc config set "$CONTAINER" limits.cpu 2
lxc config set "$CONTAINER" limits.memory 2GiB

echo "=== Starting container ==="
lxc start "$CONTAINER"
sleep 5

echo "=== Installing MySQL ==="
lxc exec "$CONTAINER" -- apt-get update -qq
lxc exec "$CONTAINER" -- apt-get install -y -qq mysql-server mysql-client

echo "=== Configuring MySQL ==="
lxc exec "$CONTAINER" -- mysql -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'csphere-admin';
CREATE USER IF NOT EXISTS 'csphere'@'%' IDENTIFIED WITH mysql_native_password BY 'csphere-pass';
GRANT ALL PRIVILEGES ON csphere.* TO 'csphere'@'%';
FLUSH PRIVILEGES;
SQL

echo "=== Binding MySQL to 0.0.0.0 ==="
lxc exec "$CONTAINER" -- sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
lxc exec "$CONTAINER" -- systemctl restart mysql

echo "=== Importing schema ==="
lxc file push schema.sql "$CONTAINER"/tmp/schema.sql
lxc exec "$CONTAINER" -- mysql -u root -pcsphere-admin < /tmp/schema.sql

echo "=== Done ==="
echo "Container: $CONTAINER"
echo "MySQL host: $(lxc list "$CONTAINER" --format=json | jq -r '.[0].state.network.eth0.addresses[] | select(.family=="inet") | .address')"
echo "User: csphere / csphere-pass"
echo "Database: csphere"
