CREATE DATABASE IF NOT EXISTS `swp_card_store`;
USE `swp_card_store`;

-- =============================================
-- 1. USERS
-- =============================================
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `phone_number` varchar(15) DEFAULT NULL,
  `balance` decimal(15,2) DEFAULT '0.00',
  `role` enum('ADMIN','CUSTOMER') DEFAULT 'CUSTOMER',
  `status` enum('ACTIVE','BANNED') DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  `created_by` int DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 2. VOUCHERS
-- =============================================
DROP TABLE IF EXISTS `vouchers`;
CREATE TABLE `vouchers` (
  `voucher_id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `discount_type` enum('PERCENT','FIXED') NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `min_order_value` decimal(15,2) DEFAULT '0.00',
  `usage_limit` int DEFAULT NULL,
  `used_count` int DEFAULT 0,
  `expiry_date` datetime DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  `created_by` int DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  PRIMARY KEY (`voucher_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 3. PROVIDERS
-- =============================================
DROP TABLE IF EXISTS `providers`;
CREATE TABLE `providers` (
  `provider_id` int NOT NULL AUTO_INCREMENT,
  `provider_name` varchar(50) NOT NULL,
  `provider_type` enum('TEL','GAME') DEFAULT 'TEL',
  `image_url` varchar(255) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  `created_by` int DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  PRIMARY KEY (`provider_id`),
  UNIQUE KEY `provider_name` (`provider_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 4. PRODUCTS
-- =============================================
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `description` text,
  `image_url` varchar(255) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  `created_by` int DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  KEY `provider_id` (`provider_id`),
  CONSTRAINT `products_provider_fk` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 5. PRODUCT STORAGE
-- =============================================
DROP TABLE IF EXISTS `product_storage`;
CREATE TABLE `product_storage` (
  `storage_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `serial_number` varchar(50) NOT NULL,
  `card_code` varchar(50) NOT NULL,
  `expiry_date` date DEFAULT NULL,
  `status` enum('AVAILABLE','SOLD','ERROR') DEFAULT 'AVAILABLE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  `created_by` int DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  PRIMARY KEY (`storage_id`),
  KEY `idx_product_status` (`product_id`, `status`),
  CONSTRAINT `storage_product_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 6. ORDERS
-- =============================================
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  
  -- Product snapshot
  `product_id` int NOT NULL,
  `provider_name` varchar(50) NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity` int NOT NULL,
  
  -- Product log JSON, populated on COMPLETED
  `product_log` json DEFAULT NULL,
  
  -- Voucher snapshot
  `voucher_id` int DEFAULT NULL,
  `voucher_code` varchar(50) DEFAULT NULL,
  `discount_amount` decimal(15,2) DEFAULT '0.00',
  
  -- Financials
  `total_amount` decimal(15,2) NOT NULL,
  `status` enum('PENDING','PROCESSING','COMPLETED','FAILED') DEFAULT 'PENDING',
  
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  `created_by` int DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  
  PRIMARY KEY (`order_id`),
  KEY `user_id` (`user_id`),
  KEY `voucher_id` (`voucher_id`),
  CONSTRAINT `orders_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT,
  CONSTRAINT `orders_voucher_fk` FOREIGN KEY (`voucher_id`) REFERENCES `vouchers` (`voucher_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 7. TRANSACTIONS
-- =============================================
DROP TABLE IF EXISTS `transactions`;
CREATE TABLE `transactions` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `order_id` int DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transaction_type` enum('DEPOSIT','PAYMENT','REFUND') NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` enum('PENDING','SUCCESS','FAILED') DEFAULT 'SUCCESS',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  `created_by` int DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `user_id` (`user_id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `trans_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT,
  CONSTRAINT `trans_order_fk` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 8. PAYMENT GATEWAY TRANSACTIONS
-- =============================================
DROP TABLE IF EXISTS `payment_gateway_transactions`;
CREATE TABLE `payment_gateway_transactions` (
  `pg_id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int NOT NULL,
  `gateway_name` enum('VNPAY','MOMO') NOT NULL,
  `payment_ref_id` varchar(100) DEFAULT NULL,
  `gateway_transaction_id` varchar(100) DEFAULT NULL,
  `amount` decimal(15,2) DEFAULT NULL,
  `bank_code` varchar(20) DEFAULT NULL,
  `response_code` varchar(10) DEFAULT NULL,
  `full_response_log` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  `created_by` int DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  PRIMARY KEY (`pg_id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  CONSTRAINT `pg_trans_fk` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 9. FEEDBACKS
-- =============================================
DROP TABLE IF EXISTS `feedbacks`;
CREATE TABLE `feedbacks` (
  `feedback_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `content` text NOT NULL,
  `rating` int DEFAULT NULL,
  `status` enum('PENDING','RESOLVED','HIDDEN') DEFAULT 'PENDING',
  `is_visible` bit(1) DEFAULT b'0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  `created_by` int DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  PRIMARY KEY (`feedback_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `feedbacks_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT,
  CONSTRAINT `feedbacks_chk_rating` CHECK (((`rating` >= 1) and (`rating` <= 5)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- SAMPLE DATA
-- =============================================

-- Users (admin:  created_by = NULL, customer: created_by = self)
INSERT INTO `users` (`user_id`,`username`,`password`,`email`,`full_name`,`phone_number`,`balance`,`role`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
(1,'admin','$2a$10$N9qo8uLOickgx2ZMRZoMyeUPQ0dfLwCcTVqPMGmKxD6xYQewHbPW. ','admin@store. com','Super Admin',NULL,0.00,'ADMIN','ACTIVE',NOW(),NOW(),b'0',NULL,NULL),
(2,'customer1','$2a$10$N9qo8uLOickgx2ZMRZoMyeUPQ0dfLwCcTVqPMGmKxD6xYQewHbPW.','khach@gmail.com','Nguyen Van A','0901234567',500000.00,'CUSTOMER','ACTIVE',NOW(),NOW(),b'0',2,NULL);

-- Providers (created by admin)
INSERT INTO `providers` (`provider_id`,`provider_name`,`provider_type`,`image_url`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
(1,'Viettel','TEL',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(2,'Vinaphone','TEL',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(3,'Garena','GAME',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL);

-- Products (created by admin)
INSERT INTO `products` (`product_id`,`provider_id`,`product_name`,`price`,`description`,`image_url`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
(1,1,'Viettel 10k',10000.00,NULL,NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(2,1,'Viettel 50k',50000.00,NULL,NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(3,3,'Garena 20k',20000.00,NULL,NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL);

-- Product Storage (created by admin)
INSERT INTO `product_storage` (`storage_id`,`product_id`,`serial_number`,`card_code`,`expiry_date`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
(1,1,'SER_VT10_01','CODE_1111',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(2,1,'SER_VT10_02','CODE_2222',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(3,2,'SER_VT50_01','CODE_3333',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(4,3,'SER_GA20_01','CODE_4444',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL);

-- Vouchers (created by admin)
INSERT INTO `vouchers` (`voucher_id`,`code`,`discount_type`,`discount_value`,`min_order_value`,`usage_limit`,`used_count`,`expiry_date`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
(1,'WELCOME10','PERCENT',10.00,50000.00,100,0,'2025-12-31 23:59:59','ACTIVE',NOW(),NOW(),b'0',1,NULL),
(2,'SALE5K','FIXED',5000.00,20000.00,50,0,'2025-12-31 23:59:59','ACTIVE',NOW(),NOW(),b'0',1,NULL);