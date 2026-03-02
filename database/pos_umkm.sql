-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: mysql:3306
-- Generation Time: Jan 14, 2026 at 06:16 AM
-- Server version: 8.4.7
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pos_umkm`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`%` PROCEDURE `UpdateStockAfterTransaction` (IN `p_product_id` INT, IN `p_qty_sold` INT)   BEGIN
    -- Kurangi stok produk
    UPDATE products 
    SET stock = stock - p_qty_sold,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_product_id;
    
    -- Kurangi stok bahan baku berdasarkan resep
    UPDATE raw_materials rm
    JOIN product_recipes pr ON rm.id = pr.material_id
    SET rm.stock = rm.stock - (pr.quantity_used * p_qty_sold),
        rm.updated_at = CURRENT_TIMESTAMP
    WHERE pr.product_id = p_product_id;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`%` FUNCTION `CalculateProductProfit` (`p_selling_price` DECIMAL(10,2), `p_cost_price` DECIMAL(10,2)) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    RETURN p_selling_price - p_cost_price;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `cost_price` decimal(10,2) NOT NULL,
  `selling_price` decimal(10,2) NOT NULL,
  `stock` bigint DEFAULT '0',
  `category` varchar(50) DEFAULT 'Umum',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `cost_price`, `selling_price`, `stock`, `category`, `created_at`, `updated_at`, `deleted_at`, `image`) VALUES
(1, 'Roti Tawar', 8000.00, 15000.00, 9, 'Roti', '2026-01-14 02:07:34.000', '2026-01-14 10:49:33.912', NULL, NULL),
(2, 'Kue Brownies', 12000.00, 25000.00, 14, 'Kue', '2026-01-14 02:07:34.000', '2026-01-14 11:38:33.004', NULL, NULL),
(3, 'Donat', 5000.00, 10000.00, 22, 'Kue', '2026-01-14 02:07:34.000', '2026-01-14 11:38:32.996', NULL, NULL),
(4, 'Kopi Susu', 8000.00, 15000.00, 0, 'Minuman', '2026-01-14 02:07:34.000', '2026-01-14 02:07:34.000', '2026-01-14 10:30:54.470', NULL),
(5, 'Es Teh Manis', 3000.00, 8000.00, 0, 'Minuman', '2026-01-14 02:07:34.000', '2026-01-14 02:07:34.000', '2026-01-14 10:30:58.544', NULL),
(6, 'Test Product', 5000.00, 10000.00, 10, 'Umum', '2026-01-14 09:27:45.474', '2026-01-14 09:27:45.474', '2026-01-14 10:41:31.304', NULL),
(7, 'Test CRUD Product UPDATED', 6000.00, 12000.00, 75, 'Test', '2026-01-14 10:28:17.112', '2026-01-14 10:28:17.142', '2026-01-14 10:28:17.171', NULL),
(8, 'Es teh', 4000.00, 5000.00, 22, 'Minuman', '2026-01-14 10:32:20.057', '2026-01-14 11:50:18.106', NULL, NULL),
(9, 'Test CRUD Product UPDATED', 6000.00, 12000.00, 75, 'Test', '2026-01-14 10:49:33.749', '2026-01-14 10:49:33.796', '2026-01-14 10:49:33.830', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `raw_materials`
--

CREATE TABLE `raw_materials` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `stock` decimal(10,2) NOT NULL DEFAULT '0.00',
  `unit` varchar(20) NOT NULL,
  `price_per_unit` decimal(10,2) DEFAULT '0.00',
  `min_stock` decimal(10,2) DEFAULT '10.00',
  `supplier` varchar(100) DEFAULT '',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `raw_materials`
--

INSERT INTO `raw_materials` (`id`, `name`, `stock`, `unit`, `price_per_unit`, `min_stock`, `supplier`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'Tepung Terigu', 49.00, 'kg', 12000.00, 10.00, 'Toko Bahan Kue', '2026-01-14 02:07:34.000', '2026-01-14 10:49:33.911', NULL),
(2, 'Gula Pasir', 29.40, 'kg', 15000.00, 10.00, 'Toko Bahan Kue', '2026-01-14 02:07:34.000', '2026-01-14 10:49:33.912', NULL),
(3, 'Telur', 99.00, 'butir', 2500.00, 20.00, 'Pasar Tradisional', '2026-01-14 02:07:34.000', '2026-01-14 11:38:32.994', NULL),
(4, 'Mentega', 20.00, 'kg', 45000.00, 5.00, 'Toko Bahan Kue', '2026-01-14 02:07:34.000', '2026-01-14 02:07:34.000', NULL),
(5, 'Susu Cair', 25.00, 'liter', 18000.00, 10.00, 'Supermarket', '2026-01-14 02:07:34.000', '2026-01-14 02:07:34.000', NULL),
(6, 'Test Material UPDATED', 150.00, 'kg', 6000.00, 20.00, '', '2026-01-14 10:28:17.186', '2026-01-14 10:28:17.209', NULL),
(7, 'teh', 4.00, 'pcs', 4000.00, 5.00, '', '2026-01-14 10:31:24.024', '2026-01-14 11:50:18.103', NULL),
(8, 'Es batu', 5.00, 'kg', 11000.00, 3.00, '', '2026-01-14 10:31:50.698', '2026-01-14 10:31:50.698', NULL),
(9, 'Test Material UPDATED', 150.00, 'kg', 6000.00, 20.00, '', '2026-01-14 10:49:33.851', '2026-01-14 10:49:33.877', '2026-01-14 11:26:50.979'),
(10, 'Test Low Stock Material', 3.00, 'kg', 5000.00, 10.00, '', '2026-01-14 11:17:40.075', '2026-01-14 11:17:40.075', '2026-01-14 11:26:47.173'),
(11, 'Material to Delete', 10.00, 'kg', 1000.00, 5.00, '', '2026-01-14 11:23:14.843', '2026-01-14 11:23:14.843', NULL),
(12, 'Material to Delete', 10.00, 'kg', 1000.00, 5.00, '', '2026-01-14 11:24:08.750', '2026-01-14 11:24:08.750', '2026-01-14 11:24:08.791');

-- --------------------------------------------------------

--
-- Table structure for table `recipes`
--

CREATE TABLE `recipes` (
  `id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `material_id` bigint UNSIGNED NOT NULL,
  `quantity_used` decimal(10,2) NOT NULL,
  `notes` text,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `recipes`
--

INSERT INTO `recipes` (`id`, `product_id`, `material_id`, `quantity_used`, `notes`, `created_at`, `updated_at`) VALUES
(3, 1, 1, 0.50, '', '2026-01-14 10:37:24.866', '2026-01-14 10:37:24.866'),
(4, 1, 2, 0.30, '', '2026-01-14 10:37:24.867', '2026-01-14 10:37:24.867'),
(13, 3, 3, 1.00, '', '2026-01-14 11:14:07.237', '2026-01-14 11:14:07.237'),
(15, 8, 7, 1.00, '', '2026-01-14 11:28:34.601', '2026-01-14 11:28:34.601');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` bigint UNSIGNED NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `total_profit` decimal(10,2) NOT NULL,
  `cash_received` decimal(10,2) NOT NULL,
  `change_amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(20) DEFAULT 'CASH',
  `cashier_name` varchar(100) DEFAULT 'System',
  `notes` text,
  `created_at` datetime(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`id`, `total_amount`, `total_profit`, `cash_received`, `change_amount`, `payment_method`, `cashier_name`, `notes`, `created_at`) VALUES
(1, 60000.00, 29000.00, 100000.00, 40000.00, 'cash', 'Admin', '', '2026-01-14 09:08:18.625'),
(2, 30000.00, 14000.00, 100000.00, 70000.00, 'cash', 'System', '', '2026-01-14 09:57:58.617'),
(3, 35000.00, 17000.00, 50000.00, 15000.00, 'CASH', 'Kasir UMKM', '', '2026-01-14 10:18:53.115'),
(4, 10000.00, 5000.00, 15000.00, 5000.00, 'CASH', 'Kasir UMKM', '', '2026-01-14 10:19:34.682'),
(5, 10000.00, 5000.00, 10000.00, 0.00, 'CASH', 'Kasir UMKM', '', '2026-01-14 10:19:47.778'),
(6, 15000.00, 7000.00, 50000.00, 35000.00, 'cash', 'Admin', '', '2026-01-14 10:23:44.951'),
(7, 15000.00, 7000.00, 50000.00, 35000.00, 'cash', 'Test Kasir', '', '2026-01-14 10:25:27.878'),
(8, 30000.00, 14000.00, 50000.00, 20000.00, 'cash', 'Admin Test', '', '2026-01-14 10:28:17.248'),
(9, 30000.00, 14000.00, 50000.00, 20000.00, 'cash', 'Admin Test', '', '2026-01-14 10:49:33.914'),
(10, 10000.00, 2000.00, 20000.00, 10000.00, 'CASH', 'Kasir UMKM', '', '2026-01-14 11:10:07.776'),
(11, 5000.00, 1000.00, 5000.00, 0.00, 'CASH', 'Kasir UMKM', '', '2026-01-14 11:10:41.659'),
(12, 5000.00, 1000.00, 5000.00, 0.00, 'CASH', 'Kasir UMKM', '', '2026-01-14 11:28:49.949'),
(13, 5000.00, 1000.00, 10000.00, 5000.00, 'CASH', 'Kasir UMKM', '', '2026-01-14 11:29:06.735'),
(14, 35000.00, 18000.00, 50000.00, 15000.00, 'CASH', 'Kasir UMKM', '', '2026-01-14 11:38:33.005'),
(15, 5000.00, 1000.00, 10000.00, 5000.00, 'CASH', 'Kasir UMKM', '', '2026-01-14 11:50:18.109');

-- --------------------------------------------------------

--
-- Table structure for table `transaction_details`
--

CREATE TABLE `transaction_details` (
  `id` bigint UNSIGNED NOT NULL,
  `transaction_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `product_name` varchar(100) DEFAULT NULL,
  `qty` bigint NOT NULL,
  `price_per_unit` decimal(10,2) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `profit_per_unit` decimal(10,2) NOT NULL,
  `created_at` datetime(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `transaction_details`
--

INSERT INTO `transaction_details` (`id`, `transaction_id`, `product_id`, `product_name`, `qty`, `price_per_unit`, `total_price`, `profit_per_unit`, `created_at`) VALUES
(1, 1, 1, 'Roti Tawar', 2, 15000.00, 30000.00, 7000.00, '2026-01-14 09:08:18.630'),
(2, 1, 3, 'Donat', 3, 10000.00, 30000.00, 5000.00, '2026-01-14 09:08:18.633'),
(3, 2, 1, 'Roti Tawar', 2, 15000.00, 30000.00, 7000.00, '2026-01-14 09:57:58.619'),
(4, 3, 3, 'Donat', 2, 10000.00, 20000.00, 5000.00, '2026-01-14 10:18:53.119'),
(5, 3, 1, 'Roti Tawar', 1, 15000.00, 15000.00, 7000.00, '2026-01-14 10:18:53.121'),
(6, 4, 3, 'Donat', 1, 10000.00, 10000.00, 5000.00, '2026-01-14 10:19:34.684'),
(7, 5, 3, 'Donat', 1, 10000.00, 10000.00, 5000.00, '2026-01-14 10:19:47.780'),
(8, 6, 1, 'Roti Tawar', 1, 15000.00, 15000.00, 7000.00, '2026-01-14 10:23:44.953'),
(9, 7, 1, 'Roti Tawar', 1, 15000.00, 15000.00, 7000.00, '2026-01-14 10:25:27.881'),
(10, 8, 1, 'Roti Tawar', 2, 15000.00, 30000.00, 7000.00, '2026-01-14 10:28:17.249'),
(11, 9, 1, 'Roti Tawar', 2, 15000.00, 30000.00, 7000.00, '2026-01-14 10:49:33.914'),
(12, 10, 8, 'Es teh', 2, 5000.00, 10000.00, 1000.00, '2026-01-14 11:10:07.779'),
(13, 11, 8, 'Es teh', 1, 5000.00, 5000.00, 1000.00, '2026-01-14 11:10:41.660'),
(14, 12, 8, 'Es teh', 1, 5000.00, 5000.00, 1000.00, '2026-01-14 11:28:49.951'),
(15, 13, 8, 'Es teh', 1, 5000.00, 5000.00, 1000.00, '2026-01-14 11:29:06.736'),
(16, 14, 3, 'Donat', 1, 10000.00, 10000.00, 5000.00, '2026-01-14 11:38:33.006'),
(17, 14, 2, 'Kue Brownies', 1, 25000.00, 25000.00, 13000.00, '2026-01-14 11:38:33.008'),
(18, 15, 8, 'Es teh', 1, 5000.00, 5000.00, 1000.00, '2026-01-14 11:50:18.114');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `role` varchar(20) DEFAULT 'cashier',
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` datetime(3) DEFAULT NULL,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `full_name`, `role`, `is_active`, `last_login`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'admin', 'admin123', 'Administrator', 'admin', 1, '2026-01-14 11:24:08.728', '2026-01-14 02:07:19.000', '2026-01-14 11:24:08.729', NULL),
(2, 'kasir', 'kasir123', 'Kasir', 'kasir', 1, '2026-01-14 09:27:57.194', '2026-01-14 02:07:19.000', '2026-01-14 09:27:57.194', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_products_deleted_at` (`deleted_at`);

--
-- Indexes for table `raw_materials`
--
ALTER TABLE `raw_materials`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_raw_materials_deleted_at` (`deleted_at`);

--
-- Indexes for table `recipes`
--
ALTER TABLE `recipes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `transaction_details`
--
ALTER TABLE `transaction_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uni_users_username` (`username`),
  ADD KEY `idx_users_deleted_at` (`deleted_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `raw_materials`
--
ALTER TABLE `raw_materials`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `recipes`
--
ALTER TABLE `recipes`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `transaction_details`
--
ALTER TABLE `transaction_details`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
