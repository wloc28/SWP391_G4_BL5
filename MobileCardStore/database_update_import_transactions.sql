-- =============================================
-- TẠO BẢNG IMPORT_TRANSACTIONS
-- Bảng này lưu lịch sử nhập hàng từ provider
-- =============================================

USE `swp_card_store`;

DROP TABLE IF EXISTS `import_transactions`;
CREATE TABLE `import_transactions` (
  `import_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL COMMENT 'ID của provider product',
  `product_code` varchar(50) DEFAULT NULL COMMENT 'Mã sản phẩm từ provider (VD: VT10K)',
  `product_id` int NOT NULL COMMENT 'ID sản phẩm trong hệ thống',
  `quantity` int NOT NULL COMMENT 'Số lượng nhập',
  `purchase_price` decimal(10,2) NOT NULL COMMENT 'Giá nhập từ provider',
  `total_cost` decimal(15,2) NOT NULL COMMENT 'Tổng chi phí (purchase_price * quantity)',
  `imported_by` int NOT NULL COMMENT 'Admin nhập hàng (user_id)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`import_id`),
  KEY `provider_id` (`provider_id`),
  KEY `product_id` (`product_id`),
  KEY `imported_by` (`imported_by`),
  KEY `created_at` (`created_at`),
  CONSTRAINT `import_provider_fk` 
    FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`) ON DELETE RESTRICT,
  CONSTRAINT `import_product_fk` 
    FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE RESTRICT,
  CONSTRAINT `import_user_fk` 
    FOREIGN KEY (`imported_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



