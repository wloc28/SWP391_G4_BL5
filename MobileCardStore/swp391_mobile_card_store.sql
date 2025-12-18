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
(1,'admin','12345','admin@store.com','Super Admin',NULL,0.00,'ADMIN','ACTIVE',NOW(),NOW(),b'0',NULL,NULL),
(2,'customer1','12345','khach@gmail.com','Nguyen Van A','0901234567',500000.00,'CUSTOMER','ACTIVE',NOW(),NOW(),b'0',2,NULL),
(3,'customer2','12345','tran@gmail.com','Tran Thi B','0907654321',1000000.00,'CUSTOMER','ACTIVE',NOW(),NOW(),b'0',3,NULL),
(4,'customer3','12345','le@gmail.com','Le Van C','0912345678',250000.00,'CUSTOMER','ACTIVE',NOW(),NOW(),b'0',4,NULL);

-- Providers (created by admin)
INSERT INTO `providers` (`provider_id`,`provider_name`,`provider_type`,`image_url`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
(1,'Viettel','TEL',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(2,'Vinaphone','TEL',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(3,'Mobifone','TEL',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(4,'VNPT','TEL',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(5,'Garena','GAME',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(6,'Steam','GAME',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(7,'Riot Games','GAME',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(8,'VNG','GAME',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL);

-- Products (created by admin)
INSERT INTO `products` (`product_id`,`provider_id`,`product_name`,`price`,`description`,`image_url`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
-- Viettel Cards
(1,1,'Viettel 10k',10000.00,'Thẻ điện thoại Viettel 10.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(2,1,'Viettel 20k',20000.00,'Thẻ điện thoại Viettel 20.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(3,1,'Viettel 30k',30000.00,'Thẻ điện thoại Viettel 30.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(4,1,'Viettel 50k',50000.00,'Thẻ điện thoại Viettel 50.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(5,1,'Viettel 100k',100000.00,'Thẻ điện thoại Viettel 100.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(6,1,'Viettel 200k',200000.00,'Thẻ điện thoại Viettel 200.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(7,1,'Viettel 500k',500000.00,'Thẻ điện thoại Viettel 500.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
-- Vinaphone Cards
(8,2,'Vinaphone 10k',10000.00,'Thẻ điện thoại Vinaphone 10.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(9,2,'Vinaphone 20k',20000.00,'Thẻ điện thoại Vinaphone 20.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(10,2,'Vinaphone 50k',50000.00,'Thẻ điện thoại Vinaphone 50.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(11,2,'Vinaphone 100k',100000.00,'Thẻ điện thoại Vinaphone 100.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(12,2,'Vinaphone 200k',200000.00,'Thẻ điện thoại Vinaphone 200.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
-- Mobifone Cards
(13,3,'Mobifone 10k',10000.00,'Thẻ điện thoại Mobifone 10.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(14,3,'Mobifone 20k',20000.00,'Thẻ điện thoại Mobifone 20.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(15,3,'Mobifone 50k',50000.00,'Thẻ điện thoại Mobifone 50.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(16,3,'Mobifone 100k',100000.00,'Thẻ điện thoại Mobifone 100.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
-- VNPT Cards
(17,4,'VNPT 10k',10000.00,'Thẻ điện thoại VNPT 10.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(18,4,'VNPT 50k',50000.00,'Thẻ điện thoại VNPT 50.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(19,4,'VNPT 100k',100000.00,'Thẻ điện thoại VNPT 100.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
-- Garena Cards
(20,5,'Garena 20k',20000.00,'Thẻ game Garena 20.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(21,5,'Garena 50k',50000.00,'Thẻ game Garena 50.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(22,5,'Garena 100k',100000.00,'Thẻ game Garena 100.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(23,5,'Garena 200k',200000.00,'Thẻ game Garena 200.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
-- Steam Cards
(24,6,'Steam 50k',50000.00,'Thẻ game Steam 50.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(25,6,'Steam 100k',100000.00,'Thẻ game Steam 100.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(26,6,'Steam 250k',250000.00,'Thẻ game Steam 250.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(27,6,'Steam 500k',500000.00,'Thẻ game Steam 500.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
-- Riot Games Cards
(28,7,'Riot 50k',50000.00,'Thẻ Riot Points 50.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(29,7,'Riot 100k',100000.00,'Thẻ Riot Points 100.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(30,7,'Riot 200k',200000.00,'Thẻ Riot Points 200.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
-- VNG Cards
(31,8,'VNG 20k',20000.00,'Thẻ game VNG 20.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(32,8,'VNG 50k',50000.00,'Thẻ game VNG 50.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL),
(33,8,'VNG 100k',100000.00,'Thẻ game VNG 100.000đ',NULL,'ACTIVE',NOW(),NOW(),b'0',1,NULL);

-- Product Storage (created by admin)
INSERT INTO `product_storage` (`storage_id`,`product_id`,`serial_number`,`card_code`,`expiry_date`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
-- Viettel Storage
(1,1,'SER_VT10_01','VT10CODE001','2026-12-31','SOLD',NOW(),NOW(),b'0',1,NULL),
(2,1,'SER_VT10_02','VT10CODE002','2026-12-31','SOLD',NOW(),NOW(),b'0',1,NULL),
(3,1,'SER_VT10_03','VT10CODE003','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(4,2,'SER_VT20_01','VT20CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(5,3,'SER_VT30_01','VT30CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(6,4,'SER_VT50_01','VT50CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(7,5,'SER_VT100_01','VT100CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(8,6,'SER_VT200_01','VT200CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(9,7,'SER_VT500_01','VT500CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
-- Vinaphone Storage
(10,8,'SER_VN10_01','VN10CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(11,9,'SER_VN20_01','VN20CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(12,10,'SER_VN50_01','VN50CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(13,11,'SER_VN100_01','VN100CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(14,12,'SER_VN200_01','VN200CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
-- Mobifone Storage
(15,13,'SER_MB10_01','MB10CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(16,14,'SER_MB20_01','MB20CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(17,15,'SER_MB50_01','MB50CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(18,16,'SER_MB100_01','MB100CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
-- VNPT Storage
(19,17,'SER_VP10_01','VP10CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(20,18,'SER_VP50_01','VP50CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(21,19,'SER_VP100_01','VP100CODE001','2026-12-31','AVAILABLE',NOW(),NOW(),b'0',1,NULL),
-- Garena Storage
(22,20,'SER_GA20_01','GA20CODE001',NULL,'SOLD',NOW(),NOW(),b'0',1,NULL),
(23,21,'SER_GA50_01','GA50CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(24,22,'SER_GA100_01','GA100CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(25,23,'SER_GA200_01','GA200CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
-- Steam Storage
(26,24,'SER_ST50_01','ST50CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(27,25,'SER_ST100_01','ST100CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(28,26,'SER_ST250_01','ST250CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(29,27,'SER_ST500_01','ST500CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
-- Riot Games Storage
(30,28,'SER_RT50_01','RT50CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(31,29,'SER_RT100_01','RT100CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(32,30,'SER_RT200_01','RT200CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
-- VNG Storage
(33,31,'SER_VNG20_01','VNG20CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(34,32,'SER_VNG50_01','VNG50CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL),
(35,33,'SER_VNG100_01','VNG100CODE001',NULL,'AVAILABLE',NOW(),NOW(),b'0',1,NULL);

-- Vouchers (created by admin)
INSERT INTO `vouchers` (`voucher_id`,`code`,`discount_type`,`discount_value`,`min_order_value`,`usage_limit`,`used_count`,`expiry_date`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
(1,'WELCOME10','PERCENT',10.00,50000.00,100,0,'2025-12-31 23:59:59','ACTIVE',NOW(),NOW(),b'0',1,NULL),
(2,'SALE5K','FIXED',5000.00,20000.00,50,0,'2025-12-31 23:59:59','ACTIVE',NOW(),NOW(),b'0',1,NULL);

-- Orders (created by customer)
INSERT INTO `orders` (`order_id`,`user_id`,`product_id`,`provider_name`,`product_name`,`unit_price`,`quantity`,`product_log`,`voucher_id`,`voucher_code`,`discount_amount`,`total_amount`,`status`,`created_at`,`updated_at`,`is_deleted`,`created_by`,`deleted_by`) VALUES 
-- Customer 1 Orders
(1,2,1,'Viettel','Viettel 10k',10000.00,2,'[{"serial_number":"SER_VT10_01","card_code":"VT10CODE001"},{"serial_number":"SER_VT10_02","card_code":"VT10CODE002"}]',NULL,NULL,0.00,20000.00,'COMPLETED',NOW() - INTERVAL 5 DAY,NOW() - INTERVAL 5 DAY,b'0',2,NULL),
(2,2,4,'Viettel','Viettel 50k',50000.00,1,NULL,1,'WELCOME10',5000.00,45000.00,'PROCESSING',NOW() - INTERVAL 1 DAY,NOW(),b'0',2,NULL),
(3,2,20,'Garena','Garena 20k',20000.00,1,'[{"serial_number":"SER_GA20_01","card_code":"GA20CODE001"}]',2,'SALE5K',5000.00,15000.00,'COMPLETED',NOW() - INTERVAL 3 DAY,NOW() - INTERVAL 3 DAY,b'0',2,NULL),
(4,2,1,'Viettel','Viettel 10k',10000.00,1,NULL,NULL,NULL,0.00,10000.00,'FAILED',NOW() - INTERVAL 4 DAY,NOW() - INTERVAL 4 DAY,b'0',2,NULL),
(5,2,8,'Vinaphone','Vinaphone 10k',10000.00,3,NULL,NULL,NULL,0.00,30000.00,'PENDING',NOW() - INTERVAL 1 HOUR,NOW(),b'0',2,NULL),
-- Customer 2 Orders
(6,3,25,'Steam','Steam 100k',100000.00,1,NULL,1,'WELCOME10',10000.00,90000.00,'PROCESSING',NOW() - INTERVAL 2 DAY,NOW(),b'0',3,NULL),
(7,3,29,'Riot Games','Riot 100k',100000.00,2,NULL,NULL,NULL,0.00,200000.00,'PENDING',NOW() - INTERVAL 6 HOUR,NOW(),b'0',3,NULL),
(8,3,12,'Vinaphone','Vinaphone 200k',200000.00,1,NULL,NULL,NULL,0.00,200000.00,'COMPLETED',NOW() - INTERVAL 7 DAY,NOW() - INTERVAL 7 DAY,b'0',3,NULL),
(9,3,22,'Garena','Garena 100k',100000.00,1,NULL,2,'SALE5K',5000.00,95000.00,'COMPLETED',NOW() - INTERVAL 4 DAY,NOW() - INTERVAL 4 DAY,b'0',3,NULL),
-- Customer 3 Orders
(10,4,15,'Mobifone','Mobifone 50k',50000.00,1,NULL,NULL,NULL,0.00,50000.00,'PROCESSING',NOW() - INTERVAL 3 HOUR,NOW(),b'0',4,NULL),
(11,4,31,'VNG','VNG 20k',20000.00,2,NULL,2,'SALE5K',5000.00,35000.00,'PENDING',NOW() - INTERVAL 30 MINUTE,NOW(),b'0',4,NULL),
(12,4,27,'Steam','Steam 500k',500000.00,1,NULL,NULL,NULL,0.00,500000.00,'FAILED',NOW() - INTERVAL 1 DAY,NOW() - INTERVAL 1 DAY,b'0',4,NULL),
(13,4,18,'VNPT','VNPT 50k',50000.00,1,NULL,1,'WELCOME10',5000.00,45000.00,'COMPLETED',NOW() - INTERVAL 6 DAY,NOW() - INTERVAL 6 DAY,b'0',4,NULL),
-- Mixed Orders
(14,2,26,'Steam','Steam 250k',250000.00,1,NULL,NULL,NULL,0.00,250000.00,'PENDING',NOW() - INTERVAL 15 MINUTE,NOW(),b'0',2,NULL),
(15,3,33,'VNG','VNG 100k',100000.00,1,NULL,NULL,NULL,0.00,100000.00,'PROCESSING',NOW() - INTERVAL 2 HOUR,NOW(),b'0',3,NULL),
(16,4,5,'Viettel','Viettel 100k',100000.00,2,NULL,1,'WELCOME10',20000.00,180000.00,'PENDING',NOW() - INTERVAL 45 MINUTE,NOW(),b'0',4,NULL);