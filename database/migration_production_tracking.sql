-- ============================================
-- MIGRATION: ADD PRODUCTION TRACKING TABLES
-- ============================================

USE pos_umkm;

-- Add has_recipe column to products table
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS has_recipe BOOLEAN DEFAULT FALSE 
COMMENT 'Apakah produk menggunakan resep bahan baku';

-- Create productions table
CREATE TABLE IF NOT EXISTS productions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    quantity_produced INT NOT NULL COMMENT 'Jumlah produk yang diproduksi',
    total_cost DECIMAL(10,2) NOT NULL COMMENT 'Total biaya produksi',
    cost_per_unit DECIMAL(10,2) NOT NULL COMMENT 'Biaya per unit',
    batch_number VARCHAR(50) COMMENT 'Nomor batch produksi',
    produced_by VARCHAR(100) DEFAULT 'System' COMMENT 'Nama yang melakukan produksi',
    notes TEXT COMMENT 'Catatan produksi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) 
        REFERENCES products(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    INDEX idx_product_id (product_id),
    INDEX idx_created_at (created_at),
    INDEX idx_batch_number (batch_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create production_materials table (detail bahan yang digunakan)
CREATE TABLE IF NOT EXISTS production_materials (
    id INT PRIMARY KEY AUTO_INCREMENT,
    production_id INT NOT NULL,
    material_id INT NOT NULL,
    quantity_used DECIMAL(10,2) NOT NULL COMMENT 'Jumlah bahan yang digunakan',
    cost DECIMAL(10,2) NOT NULL COMMENT 'Biaya bahan',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (production_id) 
        REFERENCES productions(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    FOREIGN KEY (material_id) 
        REFERENCES raw_materials(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    INDEX idx_production_id (production_id),
    INDEX idx_material_id (material_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Update existing products with recipes to set has_recipe = true
UPDATE products p
SET has_recipe = TRUE
WHERE EXISTS (
    SELECT 1 FROM product_recipes pr 
    WHERE pr.product_id = p.id
);

SELECT '✅ Migration completed: Production tracking tables created' as status;
