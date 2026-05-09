# cSphere Database (csphere-db)

MySQL schema and deployment for the cSphere platform.

## Tables

### `users`
Platform users with bcrypt-hashed passwords and LXD tenant binding.

| Column     | Type          | Description             |
|------------|---------------|-------------------------|
| id         | VARCHAR(64)   | Primary key             |
| email      | VARCHAR(255)  | Unique login email      |
| name       | VARCHAR(255)  | Display name            |
| hash       | VARCHAR(255)  | bcrypt password hash    |
| tenant_id  | VARCHAR(128)  | LXD project/tenant ref  |
| admin      | TINYINT(1)    | Admin flag              |
| created_at | TIMESTAMP     | Account creation date   |

### `billings`
Billing records linked to users.

| Column     | Type           | Description                    |
|------------|----------------|--------------------------------|
| id         | BIGINT UNSIGNED| Auto-increment PK              |
| user_id    | VARCHAR(64)    | FK to users.id                 |
| email      | VARCHAR(255)   | User email                     |
| status     | ENUM           | ACTIVE / PENDING / OVERDUE / SUSPENDED |
| plan       | VARCHAR(64)    | Subscription plan (mc-t1, etc) |
| amount     | DECIMAL(12,2)  | Monthly amount                 |
| due_date   | DATE           | Next payment due date          |
| updated_at | TIMESTAMP      | Last update                    |

## Deploy

### 1. Create LXC container

```bash
# On the LXD host
lxc launch ubuntu:22.04 lxc-db
```

### 2. Install MySQL

```bash
lxc exec lxc-db -- apt-get update -qq
lxc exec lxc-db -- apt-get install -y -qq mysql-server mysql-client
```

### 3. Configure MySQL

```bash
lxc exec lxc-db -- mysql -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'csphere-admin';
CREATE USER IF NOT EXISTS 'csphere'@'%' IDENTIFIED BY 'csphere-pass';
GRANT ALL PRIVILEGES ON csphere.* TO 'csphere'@'%';
FLUSH PRIVILEGES;
SQL

lxc exec lxc-db -- sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
lxc exec lxc-db -- systemctl restart mysql
```

### 4. Import schema

```bash
lxc file push schema.sql lxc-db/tmp/schema.sql
lxc exec lxc-db -- mysql -u root -pcsphere-admin < /tmp/schema.sql
```

### 5. Get connection info

```bash
lxc list lxc-db --format=json | jq -r '.[0].state.network.eth0.addresses[] | select(.family=="inet") | .address'
```

## Quick Deploy (all-in-one)

```bash
chmod +x deploy/lxc-create.sh
./deploy/lxc-create.sh lxc-db
```

## Application Config

The backend expects these environment variables:

```ini
DB_HOST=<lxc-db-ip>
DB_PORT=3306
DB_USER=csphere
DB_PASSWORD=csphere-pass
DB_NAME=csphere
```
