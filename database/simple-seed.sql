-- Simple seeder untuk testing
USE pos_umkm;

-- Insert users (password: admin123 dan kasir123)
INSERT IGNORE INTO users (username, password, full_name, role) VALUES
('admin', 'admin123', 'Administrator', 'admin'),
('kasir', 'kasir123', 'Kasir Utama', 'kasir');

-- Insert produk
INSERT IGNORE INTO products (name, cost_price, selling_price, stock, category) VALUES
('Kopi Susu', 3000.00, 8000.00, 100, 'Minuman'),
('Teh Tarik', 2500.00, 7000.00, 80, 'Minuman'),
('Nasi Goreng', 8000.00, 15000.00, 50, 'Makanan'),
('Kentang Goreng', 5000.00, 10000.00, 60, 'Snack');

-- Insert bahan baku
INSERT IGNORE INTO raw_materials (name, stock, unit, price_per_unit, min_stock) VALUES
('Biji Kopi', 5000.00, 'gr', 0.50, 500.00),
('Susu Cair', 10000.00, 'ml', 0.30, 1000.00),
('Beras', 50000.00, 'gr', 0.15, 5000.00),
('Kentang', 30000.00, 'gr', 0.25, 3000.00);

SELECT 'Seeder completed!' as status;
