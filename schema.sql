-- cSphere Database Schema
-- Database: csphere
-- Engine: MySQL 8.0+

CREATE DATABASE IF NOT EXISTS csphere
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE csphere;

-- ============================================================
-- Users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id         VARCHAR(64)    NOT NULL PRIMARY KEY,
  email      VARCHAR(255)   NOT NULL,
  name       VARCHAR(255)   NOT NULL DEFAULT '',
  hash       VARCHAR(255)   NOT NULL COMMENT 'bcrypt password hash',
  tenant_id  VARCHAR(128)   NOT NULL DEFAULT '',
  admin      TINYINT(1)     NOT NULL DEFAULT 0,
  created_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uk_users_email (email),
  KEY idx_users_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Billing Records
-- ============================================================
CREATE TABLE IF NOT EXISTS billings (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id    VARCHAR(64)     NOT NULL,
  email      VARCHAR(255)    NOT NULL,
  status     ENUM('ACTIVE','PENDING','OVERDUE','SUSPENDED') NOT NULL DEFAULT 'PENDING',
  plan       VARCHAR(64)     NOT NULL DEFAULT 'mc-t1',
  amount     DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
  due_date   DATE            DEFAULT NULL,
  updated_at TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  KEY idx_billings_user (user_id),
  KEY idx_billings_email (email),
  KEY idx_billings_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Seed: default admin user (password: admin123)
-- ============================================================
INSERT INTO users (id, email, name, hash, tenant_id, admin, created_at) VALUES
  ('admin-1', 'admin@csphere.cloud', 'Administrator',
   '$2a$10$BPce1n0iZDTqp4sksbwpzuQYp7wHDfLnzbefz6sHG9..sFbpHf2hW',
   'admin', 1, NOW())
ON DUPLICATE KEY UPDATE id=id;
