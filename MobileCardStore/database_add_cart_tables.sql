-- =============================================
-- TẠO BẢNG CART VÀ CART_ITEMS
-- Bảng này lưu giỏ hàng của người dùng
-- =============================================

USE `swp_card_store`;

-- =============================================
-- 1. CART TABLE
-- =============================================
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
  `cart_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `voucher_id` int DEFAULT NULL COMMENT 'Voucher áp dụng cho toàn bộ giỏ hàng',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cart_id`),
  UNIQUE KEY `unique_user_cart` (`user_id`),
  KEY `idx_voucher` (`voucher_id`),
  CONSTRAINT `cart_user_fk` 
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `cart_voucher_fk` 
    FOREIGN KEY (`voucher_id`) REFERENCES `vouchers` (`voucher_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 2. CART_ITEMS TABLE
-- =============================================
DROP TABLE IF EXISTS `cart_items`;
CREATE TABLE `cart_items` (
  `cart_item_id` int NOT NULL AUTO_INCREMENT,
  `cart_id` int NOT NULL,
  `product_code` varchar(50) NOT NULL COMMENT 'Mã sản phẩm',
  `provider_id` int NOT NULL COMMENT 'ID nhà cung cấp',
  `product_name` varchar(100) NOT NULL COMMENT 'Tên sản phẩm (snapshot)',
  `provider_name` varchar(50) NOT NULL COMMENT 'Tên nhà cung cấp (snapshot)',
  `unit_price` decimal(10,2) NOT NULL COMMENT 'Giá tại thời điểm thêm vào giỏ',
  `quantity` int NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cart_item_id`),
  KEY `idx_cart` (`cart_id`),
  KEY `idx_product` (`product_code`, `provider_id`),
  UNIQUE KEY `unique_cart_product` (`cart_id`, `product_code`, `provider_id`),
  CONSTRAINT `cart_items_cart_fk` 
    FOREIGN KEY (`cart_id`) REFERENCES `cart` (`cart_id`) ON DELETE CASCADE,
  CONSTRAINT `cart_items_provider_fk` 
    FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

