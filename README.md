# cSphere Database

MySQL schema for the cSphere platform.

## Quick Start

```bash
mysql -u root -p < schema.sql
```

## Tables

- `users` — Platform users with bcrypt-hashed passwords
- `billings` — Billing records per user

## Environment

```ini
DB_HOST=localhost
DB_PORT=3306
DB_USER=csphere
DB_PASSWORD=your_password
DB_NAME=csphere
```
