-- ============================================
-- INITIALIZATION SCRIPT FOR POS UMKM DATABASE
-- Database: pos_umkm
-- User: jarvis
-- ============================================

-- Buat database jika belum ada
CREATE DATABASE IF NOT EXISTS pos_umkm 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE pos_umkm;

-- ============================================
-- 1. TABEL PRODUCTS (PRODUK JADI)
-- ============================================
CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL COMMENT 'Harga modal per unit',
    selling_price DECIMAL(10,2) NOT NULL COMMENT 'Harga jual per unit',
    stock INT DEFAULT 0 COMMENT 'Stok produk jadi',
    category VARCHAR(50) DEFAULT 'Umum' COMMENT 'Kategori produk',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_category (category),
    INDEX idx_stock (stock)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 2. TABEL RAW_MATERIALS (BAHAN BAKU)
-- ============================================
CREATE TABLE IF NOT EXISTS raw_materials (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    stock DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT 'Stok bahan baku',
    unit VARCHAR(20) NOT NULL COMMENT 'Satuan (gr, ml, pcs, etc)',
    price_per_unit DECIMAL(10,2) DEFAULT 0 COMMENT 'Harga per unit bahan',
    min_stock DECIMAL(10,2) DEFAULT 10 COMMENT 'Stok minimum sebelum restock',
    supplier VARCHAR(100) DEFAULT '' COMMENT 'Nama supplier',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_stock (stock)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 3. TABEL PRODUCT_RECIPES (RESEP PRODUK)
-- ============================================
CREATE TABLE IF NOT EXISTS product_recipes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    material_id INT NOT NULL,
    quantity_used DECIMAL(10,2) NOT NULL COMMENT 'Jumlah bahan yang digunakan per 1 produk',
    notes TEXT COMMENT 'Catatan tambahan',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) 
        REFERENCES products(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    FOREIGN KEY (material_id) 
        REFERENCES raw_materials(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    UNIQUE KEY unique_product_material (product_id, material_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 4. TABEL TRANSACTIONS (TRANSAKSI PENJUALAN)
-- ============================================
CREATE TABLE IF NOT EXISTS transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    total_amount DECIMAL(10,2) NOT NULL COMMENT 'Total harga jual',
    total_profit DECIMAL(10,2) NOT NULL COMMENT 'Total keuntungan',
    cash_received DECIMAL(10,2) NOT NULL COMMENT 'Uang yang diterima',
    change_amount DECIMAL(10,2) NOT NULL COMMENT 'Kembalian',
    payment_method VARCHAR(20) DEFAULT 'CASH' COMMENT 'Metode pembayaran',
    cashier_name VARCHAR(100) DEFAULT 'System' COMMENT 'Nama kasir',
    notes TEXT COMMENT 'Catatan transaksi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 5. TABEL TRANSACTION_DETAILS (DETAIL TRANSAKSI)
-- ============================================
CREATE TABLE IF NOT EXISTS transaction_details (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    product_id INT NOT NULL,
    qty INT NOT NULL,
    price_per_unit DECIMAL(10,2) NOT NULL COMMENT 'Harga per unit saat transaksi',
    total_price DECIMAL(10,2) NOT NULL COMMENT 'qty * price_per_unit',
    profit_per_unit DECIMAL(10,2) NOT NULL COMMENT 'Keuntungan per unit',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (transaction_id) 
        REFERENCES transactions(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    FOREIGN KEY (product_id) 
        REFERENCES products(id) 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 6. TABEL USERS (UNTUK AUTHENTICATION - OPSIONAL)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'cashier', 'owner') DEFAULT 'cashier',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- DATA DUMMY UNTUK TESTING
-- ============================================

-- Hapus data lama jika ada (opsional)
-- DELETE FROM transaction_details;
-- DELETE FROM transactions;
-- DELETE FROM product_recipes;
-- DELETE FROM products;
-- DELETE FROM raw_materials;
-- DELETE FROM users;

-- Insert produk-produk umum untuk UMKM
INSERT IGNORE INTO products (name, cost_price, selling_price, stock, category) VALUES
-- Minuman
('Kopi Susu', 3000, 8000, 100, 'Minuman'),
('Teh Tarik', 2500, 7000, 80, 'Minuman'),
('Cappuccino', 4000, 10000, 50, 'Minuman'),
('Matcha Latte', 4500, 12000, 40, 'Minuman'),
('Milo Dinosaur', 3500, 9000, 60, 'Minuman'),

-- Makanan
('Nasi Goreng', 8000, 15000, 50, 'Makanan'),
('Mie Goreng', 7000, 14000, 45, 'Makanan'),
('Ayam Geprek', 10000, 20000, 30, 'Makanan'),
('Sate Ayam (10 tusuk)', 12000, 25000, 25, 'Makanan'),
('Batagor (6 pcs)', 6000, 12000, 40, 'Snack'),

-- Snack
('Kentang Goreng', 5000, 10000, 60, 'Snack'),
('Onion Rings', 4500, 9000, 55, 'Snack'),
('Singkong Keju', 4000, 8000, 70, 'Snack');

-- Insert bahan baku
INSERT IGNORE INTO raw_materials (name, stock, unit, price_per_unit, min_stock) VALUES
-- Bahan dasar minuman
('Biji Kopi', 5000, 'gr', 500, 500),
('Teh Celup', 200, 'pcs', 300, 50),
('Susu Cair', 10000, 'ml', 30, 1000),
('Gula Pasir', 20000, 'gr', 20, 1000),
('Matcha Powder', 1000, 'gr', 800, 100),

-- Bahan makanan
('Beras', 50000, 'gr', 15, 5000),
('Mie Instan', 100, 'pcs', 2500, 20),
('Ayam', 20000, 'gr', 40, 2000),
('Telur', 200, 'pcs', 2000, 20),
('Kentang', 30000, 'gr', 25, 3000),

-- Bahan tambahan
('Minyak Goreng', 20000, 'ml', 25, 2000),
('Bawang Merah', 5000, 'gr', 50, 500),
('Bawang Putih', 3000, 'gr', 60, 300),
('Cabai', 2000, 'gr', 80, 200),
('Kecap Manis', 5000, 'ml', 40, 500),

-- Bahan snack
('Tepung Terigu', 20000, 'gr', 20, 2000),
('Keju Cheddar', 5000, 'gr', 120, 500),
('Mentega', 10000, 'gr', 60, 1000);

-- Insert resep untuk beberapa produk (gunakan INSERT IGNORE untuk hindari duplikat)
INSERT IGNORE INTO product_recipes (product_id, material_id, quantity_used, notes) VALUES
-- Resep Kopi Susu (Product ID 1)
(1, 1, 15, 'Biji kopi yang digiling'),
(1, 3, 100, 'Susu cair full cream'),
(1, 4, 10, 'Gula pasir'),

-- Resep Teh Tarik (Product ID 2)
(2, 2, 1, '1 teh celup'),
(2, 3, 150, 'Susu cair'),
(2, 4, 15, 'Gula pasir'),

-- Resep Nasi Goreng (Product ID 6)
(6, 6, 200, 'Nasi putih'),
(6, 8, 100, 'Daging ayam'),
(6, 9, 1, '1 butir telur'),
(6, 11, 10, 'Minyak untuk menumis'),
(6, 12, 20, 'Bawang merah'),
(6, 13, 10, 'Bawang putih'),

-- Resep Kentang Goreng (Product ID 11)
(11, 10, 150, 'Kentang potong'),
(11, 11, 15, 'Minyak untuk menggoreng'),
(11, 17, 30, 'Tepung terigu untuk pelapis');

-- Insert user admin untuk login
INSERT IGNORE INTO users (username, password, full_name, role) VALUES
('admin', '$2a$10$YourHashedPasswordHere', 'Administrator', 'admin'),
('kasir1', '$2a$10$YourHashedPasswordHere', 'Kasir Utama', 'cashier'),
('owner', '$2a$10$YourHashedPasswordHere', 'Pemilik UMKM', 'owner');

-- ============================================
-- INSERT DATA TRANSAKSI CONTOH
-- ============================================

-- Hapus transaksi lama jika ada
-- DELETE FROM transaction_details;
-- DELETE FROM transactions;

-- Insert contoh transaksi
INSERT IGNORE INTO transactions 
(total_amount, total_profit, cash_received, change_amount, payment_method, cashier_name, notes) VALUES
(25000, 8000, 50000, 25000, 'CASH', 'Admin', 'Pembelian pertama');

SET @transaction_1 = LAST_INSERT_ID();

INSERT IGNORE INTO transactions 
(total_amount, total_profit, cash_received, change_amount, payment_method, cashier_name, notes) VALUES
(15000, 5000, 20000, 5000, 'CASH', 'Kasir 1', 'Pembelian kedua');

SET @transaction_2 = LAST_INSERT_ID();

INSERT IGNORE INTO transactions 
(total_amount, total_profit, cash_received, change_amount, payment_method, cashier_name, notes) VALUES
(30000, 12000, 50000, 20000, 'CASH', 'Admin', 'Pembelian ketiga');

SET @transaction_3 = LAST_INSERT_ID();

-- Get product IDs
SET @product_kopi_susu = (SELECT id FROM products WHERE name = 'Kopi Susu' LIMIT 1);
SET @product_teh_tarik = (SELECT id FROM products WHERE name = 'Teh Tarik' LIMIT 1);
SET @product_nasi_goreng = (SELECT id FROM products WHERE name = 'Nasi Goreng' LIMIT 1);
SET @product_kentang_goreng = (SELECT id FROM products WHERE name = 'Kentang Goreng' LIMIT 1);

-- Insert transaction details dengan IGNORE
INSERT IGNORE INTO transaction_details 
(transaction_id, product_id, qty, price_per_unit, total_price, profit_per_unit) VALUES
(@transaction_1, @product_kopi_susu, 2, 8000, 16000, 5000),
(@transaction_1, @product_teh_tarik, 1, 7000, 7000, 4500),
(@transaction_2, @product_nasi_goreng, 1, 15000, 15000, 7000),
(@transaction_3, @product_kopi_susu, 3, 8000, 24000, 5000),
(@transaction_3, @product_kentang_goreng, 1, 10000, 10000, 5000);

-- ============================================
-- VERIFIKASI DATABASE
-- ============================================
SELECT '✅ Database pos_umkm berhasil diinisialisasi' as status;

-- Tampilkan ringkasan data
SELECT 
    '📊 Ringkasan Data' as title,
    (SELECT COUNT(*) FROM products) as total_products,
    (SELECT COUNT(*) FROM raw_materials) as total_materials,
    (SELECT COUNT(*) FROM product_recipes) as total_recipes,
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM transactions) as total_transactions,
    (SELECT COUNT(*) FROM transaction_details) as total_transaction_details;

-- Tampilkan data produk
SELECT '📦 Daftar Produk' as section;
SELECT id, name, cost_price, selling_price, stock, category FROM products;

-- Tampilkan data bahan baku
SELECT '🧪 Daftar Bahan Baku' as section;
SELECT id, name, stock, unit, price_per_unit FROM raw_materials LIMIT 10;

-- Tampilkan data resep
SELECT '📝 Daftar Resep' as section;
SELECT 
    p.name as product_name,
    rm.name as material_name,
    pr.quantity_used,
    rm.unit
FROM product_recipes pr
JOIN products p ON pr.product_id = p.id
JOIN raw_materials rm ON pr.material_id = rm.id
LIMIT 10;