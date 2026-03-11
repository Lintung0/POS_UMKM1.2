#!/bin/bash

# Script untuk fix has_recipe flag di database
# Jalankan jika ada produk dengan resep tapi flag has_recipe = false

echo "🔧 FIX HAS_RECIPE FLAG"
echo "======================"
echo ""

DB_USER="root"
DB_PASS="root"
DB_NAME="pos_umkm"

echo "Memperbaiki flag has_recipe untuk semua produk..."

# Update has_recipe = true untuk produk yang punya resep
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
UPDATE products p
SET p.has_recipe = 1
WHERE EXISTS (
    SELECT 1 FROM recipes r WHERE r.product_id = p.id
);
" 2>/dev/null

# Update has_recipe = false untuk produk yang tidak punya resep
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
UPDATE products p
SET p.has_recipe = 0
WHERE NOT EXISTS (
    SELECT 1 FROM recipes r WHERE r.product_id = p.id
);
" 2>/dev/null

echo "✅ Selesai!"
echo ""
echo "Verifikasi hasil:"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    p.id,
    p.name,
    p.has_recipe,
    COUNT(r.id) AS recipe_count
FROM products p
LEFT JOIN recipes r ON p.id = r.product_id
GROUP BY p.id, p.name, p.has_recipe
ORDER BY p.id;
" 2>/dev/null

echo ""
echo "✅ Flag has_recipe sudah diperbaiki!"
