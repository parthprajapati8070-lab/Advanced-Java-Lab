-- =====================================================================
-- Database Schema for ShopSphere E-Commerce System
-- Target Engine: MySQL 8.0+
-- Character Set: utf8mb4 / utf8mb4_unicode_ci
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `shopsphere`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `shopsphere`;

-- Disable foreign key checks during schema creation/reset
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables if needed (in reverse dependency order)
DROP TABLE IF EXISTS `coupon_usage`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `coupons`;
DROP TABLE IF EXISTS `wishlist`;
DROP TABLE IF EXISTS `cart`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `addresses`;
DROP TABLE IF EXISTS `users`;

-- =====================================================================
-- 1. Table: users
-- Stores user accounts, authentication credentials, and roles.
-- =====================================================================
CREATE TABLE `users` (
    `user_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL COMMENT 'Secure hash using bcrypt, Argon2id, or PBKDF2',
    `phone_number` VARCHAR(20) NULL,
    `role` ENUM('customer', 'admin', 'vendor') NOT NULL DEFAULT 'customer',
    `status` ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uq_users_email` (`email`),
    KEY `idx_users_role` (`role`),
    KEY `idx_users_status` (`status`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 2. Table: addresses
-- Stores shipping and billing addresses for users.
-- =====================================================================
CREATE TABLE `addresses` (
    `address_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `address_type` ENUM('shipping', 'billing', 'both') NOT NULL DEFAULT 'shipping',
    `is_default` BOOLEAN NOT NULL DEFAULT FALSE,
    `recipient_name` VARCHAR(100) NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL,
    `street_address_line1` VARCHAR(255) NOT NULL,
    `street_address_line2` VARCHAR(255) NULL,
    `city` VARCHAR(100) NOT NULL,
    `state` VARCHAR(100) NOT NULL,
    `postal_code` VARCHAR(20) NOT NULL,
    `country` VARCHAR(100) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`address_id`),
    KEY `idx_addresses_user_id` (`user_id`),
    CONSTRAINT `fk_addresses_user_id`
        FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 3. Table: categories
-- Product categories supporting nested/hierarchical taxonomies.
-- =====================================================================
CREATE TABLE `categories` (
    `category_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `parent_id` INT UNSIGNED NULL,
    `name` VARCHAR(100) NOT NULL,
    `slug` VARCHAR(120) NOT NULL,
    `description` TEXT NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`category_id`),
    UNIQUE KEY `uq_categories_slug` (`slug`),
    KEY `idx_categories_parent_id` (`parent_id`),
    KEY `idx_categories_is_active` (`is_active`),
    CONSTRAINT `fk_categories_parent_id`
        FOREIGN KEY (`parent_id`)
        REFERENCES `categories` (`category_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 4. Table: products
-- Catalog products including pricing, inventory, and status.
-- =====================================================================
CREATE TABLE `products` (
    `product_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `category_id` INT UNSIGNED NULL,
    `sku` VARCHAR(64) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `slug` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `image_url` VARCHAR(500) NULL,
    `price` DECIMAL(10, 2) NOT NULL,
    `sale_price` DECIMAL(10, 2) NULL,
    `stock_quantity` INT NOT NULL DEFAULT 0,
    `status` ENUM('draft', 'active', 'out_of_stock', 'archived') NOT NULL DEFAULT 'active',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`product_id`),
    UNIQUE KEY `uq_products_sku` (`sku`),
    UNIQUE KEY `uq_products_slug` (`slug`),
    KEY `idx_products_category_id` (`category_id`),
    KEY `idx_products_status` (`status`),
    KEY `idx_products_price` (`price`),
    CONSTRAINT `fk_products_category_id`
        FOREIGN KEY (`category_id`)
        REFERENCES `categories` (`category_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 5. Table: cart
-- Stores shopping cart items associated with registered users.
-- =====================================================================
CREATE TABLE `cart` (
    `cart_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `product_id` BIGINT UNSIGNED NOT NULL,
    `quantity` INT UNSIGNED NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`cart_id`),
    UNIQUE KEY `uq_cart_user_product` (`user_id`, `product_id`),
    KEY `idx_cart_product_id` (`product_id`),
    CONSTRAINT `fk_cart_user_id`
        FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_cart_product_id`
        FOREIGN KEY (`product_id`)
        REFERENCES `products` (`product_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 6. Table: wishlist
-- Stores saved/bookmarked products for users.
-- =====================================================================
CREATE TABLE `wishlist` (
    `wishlist_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `product_id` BIGINT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`wishlist_id`),
    UNIQUE KEY `uq_wishlist_user_product` (`user_id`, `product_id`),
    KEY `idx_wishlist_product_id` (`product_id`),
    CONSTRAINT `fk_wishlist_user_id`
        FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_wishlist_product_id`
        FOREIGN KEY (`product_id`)
        REFERENCES `products` (`product_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 7. Table: coupons
-- Stores discount vouchers and promotional campaign rules.
-- =====================================================================
CREATE TABLE `coupons` (
    `coupon_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `code` VARCHAR(50) NOT NULL,
    `discount_type` ENUM('percentage', 'fixed_amount') NOT NULL,
    `discount_value` DECIMAL(10, 2) NOT NULL,
    `min_order_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `max_discount_amount` DECIMAL(10, 2) NULL COMMENT 'Applies to percentage discounts',
    `usage_limit` INT UNSIGNED NULL COMMENT 'Total allowed redemption count; NULL for unlimited',
    `usage_per_user` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Allowed redemptions per customer',
    `start_date` DATETIME NOT NULL,
    `end_date` DATETIME NOT NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`coupon_id`),
    UNIQUE KEY `uq_coupons_code` (`code`),
    KEY `idx_coupons_active_dates` (`is_active`, `start_date`, `end_date`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 8. Table: orders
-- Stores purchase orders, financial totals, and lifecycle statuses.
-- =====================================================================
CREATE TABLE `orders` (
    `order_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `order_number` VARCHAR(64) NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `shipping_address_id` BIGINT UNSIGNED NULL,
    `billing_address_id` BIGINT UNSIGNED NULL,
    `coupon_id` INT UNSIGNED NULL,
    `order_status` ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') NOT NULL DEFAULT 'pending',
    `subtotal` DECIMAL(10, 2) NOT NULL,
    `discount_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `shipping_fee` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `tax_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `total_amount` DECIMAL(10, 2) NOT NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`order_id`),
    UNIQUE KEY `uq_orders_order_number` (`order_number`),
    KEY `idx_orders_user_id` (`user_id`),
    KEY `idx_orders_shipping_address` (`shipping_address_id`),
    KEY `idx_orders_billing_address` (`billing_address_id`),
    KEY `idx_orders_coupon_id` (`coupon_id`),
    KEY `idx_orders_status` (`order_status`),
    KEY `idx_orders_created_at` (`created_at`),
    CONSTRAINT `fk_orders_user_id`
        FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT `fk_orders_shipping_address_id`
        FOREIGN KEY (`shipping_address_id`)
        REFERENCES `addresses` (`address_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT `fk_orders_billing_address_id`
        FOREIGN KEY (`billing_address_id`)
        REFERENCES `addresses` (`address_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT `fk_orders_coupon_id`
        FOREIGN KEY (`coupon_id`)
        REFERENCES `coupons` (`coupon_id`)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 9. Table: order_items
-- Line items associated with each order snapshotting historical pricing.
-- =====================================================================
CREATE TABLE `order_items` (
    `order_item_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `order_id` BIGINT UNSIGNED NOT NULL,
    `product_id` BIGINT UNSIGNED NOT NULL,
    `quantity` INT UNSIGNED NOT NULL,
    `unit_price` DECIMAL(10, 2) NOT NULL COMMENT 'Unit price at moment of purchase',
    `total_price` DECIMAL(10, 2) NOT NULL COMMENT 'quantity * unit_price',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`order_item_id`),
    KEY `idx_order_items_order_id` (`order_id`),
    KEY `idx_order_items_product_id` (`product_id`),
    CONSTRAINT `fk_order_items_order_id`
        FOREIGN KEY (`order_id`)
        REFERENCES `orders` (`order_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_order_items_product_id`
        FOREIGN KEY (`product_id`)
        REFERENCES `products` (`product_id`)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 10. Table: payments
-- Records payment attempts, transactions, and gateways.
-- =====================================================================
CREATE TABLE `payments` (
    `payment_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `order_id` BIGINT UNSIGNED NOT NULL,
    `payment_method` ENUM('credit_card', 'debit_card', 'paypal', 'stripe', 'cod', 'bank_transfer') NOT NULL,
    `transaction_id` VARCHAR(191) NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `payment_status` ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    `payment_gateway_response` TEXT NULL,
    `paid_at` DATETIME NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`payment_id`),
    UNIQUE KEY `uq_payments_transaction_id` (`transaction_id`),
    KEY `idx_payments_order_id` (`order_id`),
    KEY `idx_payments_status` (`payment_status`),
    CONSTRAINT `fk_payments_order_id`
        FOREIGN KEY (`order_id`)
        REFERENCES `orders` (`order_id`)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 11. Table: reviews
-- Customer product reviews and 1-5 star ratings.
-- =====================================================================
CREATE TABLE `reviews` (
    `review_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `product_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `rating` TINYINT UNSIGNED NOT NULL,
    `title` VARCHAR(150) NULL,
    `comment` TEXT NULL,
    `is_verified_purchase` BOOLEAN NOT NULL DEFAULT FALSE,
    `status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'approved',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`review_id`),
    UNIQUE KEY `uq_reviews_user_product` (`user_id`, `product_id`),
    KEY `idx_reviews_product_id` (`product_id`),
    KEY `idx_reviews_rating` (`rating`),
    KEY `idx_reviews_status` (`status`),
    CONSTRAINT `fk_reviews_product_id`
        FOREIGN KEY (`product_id`)
        REFERENCES `products` (`product_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_reviews_user_id`
        FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `chk_reviews_rating` CHECK (`rating` BETWEEN 1 AND 5)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- 12. Table: coupon_usage
-- Tracks redemptions of promotional coupons per user and order.
-- =====================================================================
CREATE TABLE `coupon_usage` (
    `usage_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `coupon_id` INT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `order_id` BIGINT UNSIGNED NOT NULL,
    `discount_applied` DECIMAL(10, 2) NOT NULL,
    `used_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`usage_id`),
    UNIQUE KEY `uq_coupon_order` (`coupon_id`, `order_id`),
    KEY `idx_coupon_usage_user` (`user_id`),
    KEY `idx_coupon_usage_coupon` (`coupon_id`),
    CONSTRAINT `fk_coupon_usage_coupon_id`
        FOREIGN KEY (`coupon_id`)
        REFERENCES `coupons` (`coupon_id`)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT `fk_coupon_usage_user_id`
        FOREIGN KEY (`user_id`)
        REFERENCES `users` (`user_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_coupon_usage_order_id`
        FOREIGN KEY (`order_id`)
        REFERENCES `orders` (`order_id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================================
-- Seed Initial Sample Data for Demonstration
-- =====================================================================
INSERT INTO `categories` (`category_id`, `parent_id`, `name`, `slug`, `description`, `is_active`) VALUES
(1, NULL, 'Electronics', 'electronics', 'Computers, smartphones, and high-tech gadgets.', TRUE),
(2, NULL, 'Apparel & Fashion', 'apparel-fashion', 'Modern fashion, footwear, and casual wear.', TRUE),
(3, NULL, 'Home & Living', 'home-living', 'Furniture, kitchenware, and interior accessories.', TRUE),
(4, NULL, 'Accessories', 'accessories', 'Watches, bags, headphones, and daily gear.', TRUE);

INSERT INTO `products` (`product_id`, `category_id`, `sku`, `name`, `slug`, `description`, `image_url`, `price`, `sale_price`, `stock_quantity`, `status`) VALUES
(1, 1, 'SKU-ELEC-LAPTOP-01', 'UltraBook Pro 15.6\" Laptop', 'ultrabook-pro-15', 'High-performance laptop featuring a 15.6\" Full HD display, 16GB RAM, 512GB NVMe SSD, and Intel Core i7 processor.', 'assets/images/products/laptop-01.jpg', 69999.00, 64999.00, 25, 'active'),
(2, 1, 'SKU-ELEC-PHONE-02', 'NexGen 5G Flagship Smartphone', 'nexgen-5g-smartphone', 'Next-gen flagship smartphone with 120Hz AMOLED screen, 50MP AI triple camera, and 5000mAh battery.', 'assets/images/products/smartphone-01.jpg', 44999.00, 39999.00, 50, 'active'),
(3, 1, 'SKU-ELEC-HEADPHONE-03', 'AcousticPro ANC Wireless Headphones', 'acousticpro-anc-headphones', 'Over-ear wireless headphones with active noise cancellation, high-res audio, and 40-hour battery life.', 'assets/images/products/headphones-01.jpg', 9999.00, 7999.00, 80, 'active'),
(4, 1, 'SKU-ELEC-KEYBOARD-04', 'Mechanical RGB Gaming Keyboard', 'mechanical-rgb-keyboard', 'Customizable RGB backlit mechanical keyboard with tactile blue switches and aluminum top frame.', 'assets/images/products/keyboard-01.jpg', 3499.00, 2899.00, 40, 'active'),
(5, 1, 'SKU-ELEC-MOUSE-05', 'Ergonomic Precision Wireless Mouse', 'ergonomic-wireless-mouse', 'Rechargeable multi-device Bluetooth mouse with adjustable DPI sensor and silent tactile clicks.', 'assets/images/products/mouse-01.jpg', 1999.00, 1499.00, 65, 'active'),
(6, 1, 'SKU-ELEC-WATCH-06', 'Titan AMOLED Fitness Smartwatch', 'titan-amoled-smartwatch', 'IP68 waterproof smartwatch with continuous heart-rate tracking, SpO2 sensor, and 14-day battery life.', 'assets/images/products/smartwatch-01.jpg', 6499.00, 4999.00, 60, 'active'),
(7, 1, 'SKU-ELEC-MONITOR-07', '27\" 4K UHD IPS Designer Monitor', '27-inch-4k-uhd-monitor', 'Ultra-slim bezel 27-inch 4K IPS display with 99% sRGB color accuracy, HDR10, and USB-C power delivery.', 'assets/images/products/monitor-01.jpg', 24999.00, 21999.00, 30, 'active'),
(8, 1, 'SKU-ELEC-SPEAKER-08', 'BassBoom 360° Portable Bluetooth Speaker', 'bassboom-portable-speaker', 'Rugged IPX7 waterproof wireless speaker delivering deep 360-degree sound with 24 hours of playback.', 'assets/images/products/speaker-01.jpg', 4299.00, 3499.00, 45, 'active'),
(9, 1, 'SKU-ELEC-TABLET-09', 'TabX Pro 11\" 2K Octa-Core Tablet', 'tabx-pro-11-tablet', 'Sleek metallic tablet with 11-inch 2K IPS screen, quad stereo speakers, and stylus pen support.', 'assets/images/products/tablet-01.jpg', 27999.00, 23999.00, 35, 'active'),
(10, 1, 'SKU-ELEC-CAMERA-10', '4K Ultra HD Mirrorless Camera', '4k-mirrorless-camera', 'Compact 24.2MP mirrorless digital camera with fast hybrid autofocus, 4K video recording, and interchangeable lens.', 'assets/images/products/camera-01.jpg', 54999.00, 48999.00, 15, 'active'),
(11, 1, 'SKU-ELEC-PBANK-11', '20000mAh 65W Fast Charge Power Bank', '20000mah-fast-charge-power-bank', 'High-capacity portable battery with 65W Power Delivery output capable of charging laptops and phones rapidly.', 'assets/images/products/powerbank-01.jpg', 2999.00, 2299.00, 70, 'active'),
(12, 2, 'SKU-FASH-TSHIRT-12', 'Classic Crewneck Organic Cotton T-Shirt', 'classic-crewneck-tshirt', '100% bio-washed combed organic cotton tee offering breathable comfort and a tailored modern fit.', 'assets/images/products/tshirt-01.jpg', 899.00, 699.00, 120, 'active'),
(13, 2, 'SKU-FASH-HOODIE-13', 'Heavyweight Fleece Pullover Hoodie', 'heavyweight-fleece-hoodie', 'Cozy 380 GSM brushed fleece hoodie with double-lined drawstring hood and kangaroo pouch pocket.', 'assets/images/products/hoodie-01.jpg', 2499.00, 1899.00, 65, 'active'),
(14, 2, 'SKU-FASH-JEANS-14', 'Slim Fit Stretch Indigo Denim Jeans', 'slim-fit-indigo-jeans', 'Premium authentic dark wash denim crafted with 2% elastane for flexible all-day mobility.', 'assets/images/products/jeans-01.jpg', 2799.00, 2199.00, 55, 'active'),
(15, 2, 'SKU-FASH-SNEAKER-15', 'AeroStride Urban Cushion Sneakers', 'aerostride-urban-sneakers', 'Breathable knit athletic sneakers with responsive cloud-foam sole cushioning and slip-resistant rubber tread.', 'assets/images/products/sneakers-01.jpg', 3999.00, 3299.00, 40, 'active'),
(16, 2, 'SKU-FASH-JACKET-16', 'All-Weather Windbreaker Bomber Jacket', 'all-weather-bomber-jacket', 'Lightweight water-repellent jacket featuring ribbed cuffs, zipper storm flap, and secure interior pockets.', 'assets/images/products/jacket-01.jpg', 4499.00, 3599.00, 35, 'active'),
(17, 2, 'SKU-FASH-WATCH-17', 'Heritage Chronograph Leather Watch', 'heritage-chronograph-watch', 'Sophisticated analog timepiece with genuine top-grain leather strap, sapphire crystal glass, and date display.', 'assets/images/products/watch-01.jpg', 6999.00, 5499.00, 30, 'active'),
(18, 2, 'SKU-FASH-BACKPACK-18', 'Urban Commuter Waterproof Backpack', 'urban-commuter-backpack', '28L weatherproof travel backpack featuring a TSA-approved 16\" laptop sleeve and anti-theft hidden pocket.', 'assets/images/products/backpack-01.jpg', 2899.00, 2299.00, 90, 'active'),
(19, 2, 'SKU-FASH-TSHIRT-19', 'Oversized Graphic Streetwear Tee', 'oversized-graphic-tee', 'Trendy drop-shoulder streetwear graphic t-shirt made with heavy 240 GSM breathable cotton fabric.', 'assets/images/products/tshirt-02.jpg', 1199.00, 899.00, 85, 'active'),
(20, 2, 'SKU-FASH-JACKET-20', 'Vintage Washed Denim Trucker Jacket', 'vintage-denim-jacket', 'Classic rugged trucker jacket with signature metal button closure, button-flap chest pockets, and waist adjusters.', 'assets/images/products/jacket-02.jpg', 4999.00, 3999.00, 25, 'active'),
(21, 3, 'SKU-HOME-LAMP-21', 'Minimalist LED Architecture Desk Lamp', 'minimalist-led-desk-lamp', 'Dimmable architect clamp lamp with 5 color temperatures, eye-care flicker-free LED panel, and touch controls.', 'assets/images/products/desk-lamp-01.jpg', 2499.00, 1999.00, 50, 'active'),
(22, 3, 'SKU-HOME-CHAIR-22', 'Ergonomic High-Back Mesh Office Chair', 'ergonomic-mesh-office-chair', 'Commercial-grade ergonomic desk chair with adjustable lumbar support, 3D armrests, and breathable mesh back.', 'assets/images/products/office-chair-01.jpg', 12999.00, 10499.00, 20, 'active'),
(23, 3, 'SKU-HOME-BED-23', '400 TC Egyptian Cotton Bedsheet Set', 'egyptian-cotton-bedsheet-set', 'Luxury king-size bedsheet set woven from long-staple satin cotton with matching pillowcases.', 'assets/images/products/bedsheet-01.jpg', 3299.00, 2599.00, 45, 'active'),
(24, 3, 'SKU-HOME-ORG-24', 'Multi-Tier Modular Storage Organizer', 'modular-storage-organizer', 'Collapsible closet and shelf organizer bins with reinforced handles and transparent display windows.', 'assets/images/products/storage-01.jpg', 1599.00, 1299.00, 75, 'active'),
(25, 3, 'SKU-HOME-DECOR-25', 'Artisan Ceramic Nordic Vase & Decor', 'artisan-ceramic-vase', 'Handcrafted matte ceramic decorative vase ideal for dried florals, centerpieces, or contemporary living rooms.', 'assets/images/products/vase-01.jpg', 1299.00, 999.00, 60, 'active'),
(26, 3, 'SKU-HOME-KITCHEN-26', 'Pre-Seasoned Cast Iron Chef Skillet', 'cast-iron-chef-skillet', 'Heavy-duty 10-inch pre-seasoned cast iron frying pan for stovetop, oven, and grill culinary cooking.', 'assets/images/products/skillet-01.jpg', 2199.00, 1699.00, 40, 'active'),
(27, 3, 'SKU-HOME-DIFF-27', 'Aromatherapy Ultrasonic Essential Oil Diffuser', 'ultrasonic-oil-diffuser', 'Quiet 500ml wood-grain ultrasonic cool mist humidifier with 7 soothing ambient LED light modes.', 'assets/images/products/diffuser-01.jpg', 1799.00, 1399.00, 65, 'active'),
(28, 3, 'SKU-HOME-KNIFE-28', 'Stainless Steel Precision Knife Block Set', 'knife-block-set-6pc', 'High-carbon stainless steel 6-piece kitchen knife collection with ergonomic handles and acacia wooden block.', 'assets/images/products/knives-01.jpg', 3999.00, 3199.00, 30, 'active'),
(29, 4, 'SKU-ACC-WALLET-29', 'Slim RFID-Blocking Genuine Leather Wallet', 'rfid-leather-wallet', 'Handcrafted bifold leather wallet featuring an integrated RFID signal protection layer and quick-access card slots.', 'assets/images/products/wallet-01.jpg', 1499.00, 1199.00, 95, 'active'),
(30, 4, 'SKU-ACC-SUNGLASS-30', 'Polarized UV400 Aviator Sunglasses', 'polarized-aviator-sunglasses', 'Classic metal frame aviators equipped with shatterproof polarized lenses that filter 100% of harmful UVA/UVB rays.', 'assets/images/products/sunglasses-01.jpg', 2199.00, 1699.00, 70, 'active'),
(31, 4, 'SKU-ACC-CASE-31', 'Shockproof Matte Armor Phone Case', 'shockproof-matte-phone-case', 'Military drop-tested hybrid phone case with raised camera bevels and fingerprint-resistant translucent back.', 'assets/images/products/phonecase-01.jpg', 799.00, 499.00, 150, 'active'),
(32, 4, 'SKU-ACC-CABLE-32', 'Braided 100W USB-C to USB-C Fast Cable (2m)', '100w-braided-usbc-cable', 'Nylon double-braided fast charging cable supporting 100W PD charging and 480Mbps ultra-fast data transfer.', 'assets/images/products/cable-01.jpg', 699.00, 449.00, 200, 'active'),
(33, 4, 'SKU-ACC-BAG-33', 'Executive Padded Leatherette Laptop Sleeve', 'padded-laptop-sleeve', 'Water-resistant premium leatherette envelope sleeve with soft velvet inner lining for 14-15\" notebooks.', 'assets/images/products/laptop-bag-01.jpg', 1899.00, 1399.00, 60, 'active'),
(34, 4, 'SKU-ACC-TRAVEL-34', 'Compact Compression Packing Cubes (Set of 6)', 'compression-packing-cubes', 'Double-zipper expandable compression travel organizer cubes crafted from durable ripstop nylon.', 'assets/images/products/travel-01.jpg', 1699.00, 1299.00, 80, 'active'),
(35, 4, 'SKU-ACC-PILLOW-35', 'Memory Foam Travel Neck Support Pillow', 'memory-foam-travel-pillow', '360-degree ergonomic contour travel pillow with high-density memory foam core and washable plush cover.', 'assets/images/products/pillow-01.jpg', 1199.00, 899.00, 75, 'active'),
(36, 4, 'SKU-ACC-ORGANIZER-36', 'Water-Resistant Electronic Tech Organizer Case', 'electronic-tech-organizer', 'Double-layered cable and gadgets carry case with elastic loops, mesh pockets, and water-repellent shell.', 'assets/images/products/tech-pouch-01.jpg', 1399.00, 999.00, 85, 'active');

INSERT INTO `coupons` (`coupon_id`, `code`, `discount_type`, `discount_value`, `min_order_amount`, `max_discount_amount`, `usage_limit`, `usage_per_user`, `start_date`, `end_date`, `is_active`) VALUES
(1, 'SAVE10', 'percentage', 10.00, 50.00, 25.00, 500, 2, '2025-01-01 00:00:00', '2030-12-31 23:59:59', TRUE),
(2, 'WELCOME20', 'fixed_amount', 20.00, 100.00, NULL, 1000, 1, '2025-01-01 00:00:00', '2030-12-31 23:59:59', TRUE);

-- Password for both accounts is 'Password123!' (hashed with PBKDF2)
INSERT INTO `users` (`user_id`, `first_name`, `last_name`, `email`, `password_hash`, `phone_number`, `role`, `status`) VALUES
(1, 'Admin', 'User', 'admin@shopsphere.com', '65536:s4mPLe5aLtValUE1234:s4mPLeH4shValUE1234567890abcdef', '555-0100', 'admin', 'active'),
(2, 'Jane', 'Doe', 'customer@shopsphere.com', '65536:s4mPLe5aLtValUE1234:s4mPLeH4shValUE1234567890abcdef', '555-0101', 'customer', 'active');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;


