-- =============================================
-- TẠO BẢNG PRODUCT_STATUS
-- Bảng này lưu trạng thái bán hàng của sản phẩm (ACTIVE/INACTIVE)
-- =============================================

USE `swp_card_store`;

DROP TABLE IF EXISTS `product_status`;
CREATE TABLE `product_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_code` varchar(50) NOT NULL,
  `provider_id` int NOT NULL,
  `status` enum('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_product_provider` (`product_code`, `provider_id`),
  KEY `idx_product_code` (`product_code`),
  KEY `idx_provider_id` (`provider_id`),
  CONSTRAINT `product_status_provider_fk` 
    FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default ACTIVE status for all existing products
INSERT INTO product_status (product_code, provider_id, status)
SELECT DISTINCT product_code, provider_id, 'ACTIVE'
FROM product_storage
WHERE is_deleted = 0
ON DUPLICATE KEY UPDATE status = 'ACTIVE';

