-- ============================================
-- SAFE DATABASE MIGRATION FOR POS UMKM
-- Menambahkan Foreign Key Constraints yang Aman
-- ============================================

USE pos_umkm;

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- 1. ADD FOREIGN KEY CONSTRAINTS
-- ============================================

-- Add foreign keys to recipes table (product_recipes in SQL)
ALTER TABLE recipes 
ADD CONSTRAINT fk_recipes_product 
    FOREIGN KEY (product_id) REFERENCES products(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE recipes 
ADD CONSTRAINT fk_recipes_material 
    FOREIGN KEY (material_id) REFERENCES raw_materials(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Add unique constraint to prevent duplicate recipes
ALTER TABLE recipes 
ADD CONSTRAINT uk_product_material 
    UNIQUE KEY (product_id, material_id);

-- Add foreign keys to transaction_details table
ALTER TABLE transaction_details 
ADD CONSTRAINT fk_transaction_details_transaction 
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE transaction_details 
ADD CONSTRAINT fk_transaction_details_product 
    FOREIGN KEY (product_id) REFERENCES products(id) 
    ON DELETE RESTRICT ON UPDATE CASCADE;

-- ============================================
-- 2. ADD SAFETY CONSTRAINTS
-- ============================================

-- Ensure positive values
ALTER TABLE products 
ADD CONSTRAINT chk_products_positive_prices 
    CHECK (cost_price >= 0 AND selling_price >= 0 AND stock >= 0);

ALTER TABLE raw_materials 
ADD CONSTRAINT chk_materials_positive_values 
    CHECK (stock >= 0 AND price_per_unit >= 0 AND min_stock >= 0);

ALTER TABLE recipes 
ADD CONSTRAINT chk_recipes_positive_quantity 
    CHECK (quantity_used > 0);

ALTER TABLE transactions 
ADD CONSTRAINT chk_transactions_positive_amounts 
    CHECK (total_amount >= 0 AND cash_received >= 0 AND change_amount >= 0);

ALTER TABLE transaction_details 
ADD CONSTRAINT chk_transaction_details_positive 
    CHECK (qty > 0 AND price_per_unit >= 0 AND total_price >= 0);

-- ============================================
-- 3. ADD INDEXES FOR PERFORMANCE
-- ============================================

-- Indexes for recipes
CREATE INDEX idx_recipes_product_id ON recipes(product_id);
CREATE INDEX idx_recipes_material_id ON recipes(material_id);

-- Indexes for transaction_details
CREATE INDEX idx_transaction_details_transaction_id ON transaction_details(transaction_id);
CREATE INDEX idx_transaction_details_product_id ON transaction_details(product_id);
CREATE INDEX idx_transaction_details_created_at ON transaction_details(created_at);

-- Indexes for materials
CREATE INDEX idx_materials_stock_alert ON raw_materials(stock, min_stock);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- 4. VERIFY CONSTRAINTS
-- ============================================

-- Check foreign keys
SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    REFERENCED_TABLE_NAME
FROM information_schema.TABLE_CONSTRAINTS 
WHERE TABLE_SCHEMA = 'pos_umkm' 
    AND CONSTRAINT_TYPE = 'FOREIGN KEY';

-- Check indexes
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'pos_umkm'
ORDER BY TABLE_NAME, INDEX_NAME;

SELECT '✅ Database migration completed successfully' as status;
