-- Migration script: Add 'PAYOS' to payment_gateway_transactions.gateway_name enum
-- Run this SQL script if your database already exists and needs to be updated

ALTER TABLE `payment_gateway_transactions` 
MODIFY COLUMN `gateway_name` enum('VNPAY','MOMO','PAYOS') NOT NULL;

