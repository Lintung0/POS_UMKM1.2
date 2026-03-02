-- Seeder data untuk POS UMKM (kompatibel dengan GORM)
USE pos_umkm;

-- Insert users dengan password yang sudah di-hash (admin123 dan kasir123)
INSERT IGNORE INTO users (username, password, full_name, role) VALUES
('admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', 'admin'),
('kasir', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Kasir Utama', 'kasir');

-- Insert produk
INSERT IGNORE INTO products (name, cost_price, selling_price, stock, category) VALUES
('Kopi Susu', 3000.00, 8000.00, 100, 'Minuman'),
('Teh Tarik', 2500.00, 7000.00, 80, 'Minuman'),
('Cappuccino', 4000.00, 10000.00, 50, 'Minuman'),
('Nasi Goreng', 8000.00, 15000.00, 50, 'Makanan'),
('Mie Goreng', 7000.00, 14000.00, 45, 'Makanan'),
('Kentang Goreng', 5000.00, 10000.00, 60, 'Snack');

-- Insert bahan baku
INSERT IGNORE INTO raw_materials (name, stock, unit, price_per_unit, min_stock) VALUES
('Biji Kopi', 5000.00, 'gr', 0.50, 500.00),
('Teh Celup', 200.00, 'pcs', 300.00, 50.00),
('Susu Cair', 10000.00, 'ml', 0.30, 1000.00),
('Gula Pasir', 20000.00, 'gr', 0.20, 1000.00),
('Beras', 50000.00, 'gr', 0.15, 5000.00),
('Kentang', 30000.00, 'gr', 0.25, 3000.00);

-- Insert contoh transaksi
INSERT IGNORE INTO transactions (customer_name, total_amount, payment_method) VALUES
('Customer 1', 25000.00, 'cash'),
('Customer 2', 15000.00, 'cash');

-- Insert transaction details (menggunakan ID yang ada)
INSERT IGNORE INTO transaction_details (transaction_id, product_name, quantity, price, subtotal) VALUES
(1, 'Kopi Susu', 2, 8000.00, 16000.00),
(1, 'Teh Tarik', 1, 7000.00, 7000.00),
(2, 'Nasi Goreng', 1, 15000.00, 15000.00);

SELECT 'Database seeded successfully!' as status;
