-- ============================================
-- PENJELASAN RELASI DATABASE POS UMKM
-- ============================================

-- STRUKTUR RELASI:
-- products (1) ←→ (N) recipes (N) ←→ (1) raw_materials
--     ↓
-- transaction_details (N) ←→ (1) transactions

-- ============================================
-- 1. RAW_MATERIALS BERELASI LEWAT RECIPES
-- ============================================

-- Tabel raw_materials tidak langsung berelasi ke products
-- Tapi berelasi lewat tabel "recipes" (junction table)

SELECT 
    p.name as product_name,
    rm.name as material_name,
    r.quantity_used,
    rm.unit,
    rm.stock as material_stock
FROM products p
JOIN recipes r ON p.id = r.product_id
JOIN raw_materials rm ON r.material_id = rm.id
WHERE p.name = 'Kopi Susu';

-- Result:
-- product_name | material_name | quantity_used | unit | material_stock
-- Kopi Susu    | Biji Kopi     | 15.00        | gr   | 5000.00
-- Kopi Susu    | Susu Cair     | 100.00       | ml   | 10000.00  
-- Kopi Susu    | Gula Pasir    | 10.00        | gr   | 20000.00

-- ============================================
-- 2. FOREIGN KEY RELATIONSHIPS
-- ============================================

-- recipes.product_id → products.id (CASCADE DELETE/UPDATE)
-- recipes.material_id → raw_materials.id (CASCADE DELETE/UPDATE)
-- transaction_details.product_id → products.id (RESTRICT DELETE)
-- transaction_details.transaction_id → transactions.id (CASCADE DELETE)

-- ============================================
-- 3. BUSINESS LOGIC FLOW
-- ============================================

-- SAAT PENJUALAN:
-- 1. Ambil produk yang dijual
-- 2. Cek apakah produk punya resep (recipes)
-- 3. Jika punya resep:
--    - Kurangi stok raw_materials berdasarkan recipes
--    - Tidak kurangi stok products
-- 4. Jika tidak punya resep:
--    - Kurangi stok products langsung

-- SAAT PRODUKSI:
-- 1. Pilih produk yang mau diproduksi
-- 2. Ambil semua recipes untuk produk tersebut
-- 3. Kurangi stok raw_materials sesuai recipes
-- 4. Tambah stok products

-- ============================================
-- 4. CONTOH QUERY UNTUK CEK RELASI
-- ============================================

-- Cek produk mana saja yang menggunakan bahan baku tertentu
SELECT 
    rm.name as material_name,
    p.name as product_name,
    r.quantity_used
FROM raw_materials rm
JOIN recipes r ON rm.id = r.material_id  
JOIN products p ON r.product_id = p.id
WHERE rm.name = 'Biji Kopi';

-- Cek total kebutuhan bahan baku untuk produksi
SELECT 
    rm.name as material_name,
    rm.stock as current_stock,
    SUM(r.quantity_used * 10) as needed_for_10_products,
    (rm.stock - SUM(r.quantity_used * 10)) as remaining_stock
FROM raw_materials rm
JOIN recipes r ON rm.id = r.material_id
JOIN products p ON r.product_id = p.id  
WHERE p.name = 'Kopi Susu'
GROUP BY rm.id, rm.name, rm.stock;

-- ============================================
-- 5. KESIMPULAN
-- ============================================

-- RAW_MATERIALS BERELASI dengan:
-- ✅ recipes (direct foreign key)
-- ✅ products (indirect via recipes)  
-- ✅ transactions (indirect via products → recipes)

-- Jadi raw_materials TIDAK STANDALONE, tapi bagian dari:
-- Material → Recipe → Product → Transaction flow
