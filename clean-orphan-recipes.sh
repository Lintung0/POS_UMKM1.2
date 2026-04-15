#!/bin/bash

# Script untuk cek dan bersihkan semua orphan recipes

echo "🧹 CLEAN ORPHAN RECIPES"
echo "======================="
echo ""

DB_USER="root"
DB_PASS="root"
DB_NAME="pos_umkm"

echo "1️⃣  Cek orphan recipes (product tidak ada)..."
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    r.id AS recipe_id,
    r.product_id,
    r.material_id,
    m.name AS material_name,
    r.quantity_used,
    'ORPHAN: Product not found' AS status
FROM recipes r
LEFT JOIN products p ON r.product_id = p.id
LEFT JOIN materials m ON r.material_id = m.id
WHERE p.id IS NULL;
" 2>/dev/null

ORPHAN_COUNT=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -se "
SELECT COUNT(*) 
FROM recipes r
LEFT JOIN products p ON r.product_id = p.id
WHERE p.id IS NULL;
" 2>/dev/null)

echo ""
echo "Ditemukan: $ORPHAN_COUNT orphan recipes"

if [ "$ORPHAN_COUNT" -gt 0 ]; then
    echo ""
    read -p "Hapus semua orphan recipes? (yes/no): " CONFIRM
    
    if [ "$CONFIRM" = "yes" ]; then
        mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
        DELETE r FROM recipes r
        LEFT JOIN products p ON r.product_id = p.id
        WHERE p.id IS NULL;
        " 2>/dev/null
        
        echo "✅ Orphan recipes dihapus!"
    else
        echo "❌ Dibatalkan"
    fi
fi

echo ""
echo "2️⃣  Cek recipes dengan material tidak ada..."
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    r.id AS recipe_id,
    r.product_id,
    p.name AS product_name,
    r.material_id,
    'ORPHAN: Material not found' AS status
FROM recipes r
LEFT JOIN materials m ON r.material_id = m.id
LEFT JOIN products p ON r.product_id = p.id
WHERE m.id IS NULL;
" 2>/dev/null

ORPHAN_MAT_COUNT=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -se "
SELECT COUNT(*) 
FROM recipes r
LEFT JOIN materials m ON r.material_id = m.id
WHERE m.id IS NULL;
" 2>/dev/null)

echo ""
echo "Ditemukan: $ORPHAN_MAT_COUNT recipes dengan material tidak ada"

if [ "$ORPHAN_MAT_COUNT" -gt 0 ]; then
    echo ""
    read -p "Hapus recipes dengan material tidak ada? (yes/no): " CONFIRM
    
    if [ "$CONFIRM" = "yes" ]; then
        mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
        DELETE r FROM recipes r
        LEFT JOIN materials m ON r.material_id = m.id
        WHERE m.id IS NULL;
        " 2>/dev/null
        
        echo "✅ Recipes dengan material tidak ada dihapus!"
    else
        echo "❌ Dibatalkan"
    fi
fi

echo ""
echo "3️⃣  Update has_recipe flags..."
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
UPDATE products p
SET p.has_recipe = CASE
    WHEN EXISTS (SELECT 1 FROM recipes r WHERE r.product_id = p.id) THEN 1
    ELSE 0
END;
" 2>/dev/null

echo "✅ Flags updated"

echo ""
echo "📊 FINAL STATUS:"
echo "─────────────────────────────────────────"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    'Total Products' AS info,
    COUNT(*) AS count
FROM products
UNION ALL
SELECT 
    'Products with recipes' AS info,
    COUNT(*) AS count
FROM products
WHERE has_recipe = 1
UNION ALL
SELECT 
    'Total Recipes' AS info,
    COUNT(*) AS count
FROM recipes
UNION ALL
SELECT 
    'Total Materials' AS info,
    COUNT(*) AS count
FROM materials;
" 2>/dev/null

echo ""
echo "✅ Selesai! Sekarang coba hapus bahan baku lagi."
