#!/bin/bash

# Script untuk testing pengurangan stok
# Jalankan setelah melakukan transaksi

echo "🔍 VERIFIKASI PENGURANGAN STOK"
echo "================================"
echo ""

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database credentials (sesuaikan dengan .env)
DB_USER="root"
DB_PASS="root"
DB_NAME="pos_umkm"

echo "📊 CEK PRODUK & RESEP:"
echo "----------------------"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    p.id,
    p.name AS produk,
    p.stock AS stok_produk,
    p.has_recipe,
    COUNT(r.id) AS jumlah_resep
FROM products p
LEFT JOIN recipes r ON p.id = r.product_id
GROUP BY p.id, p.name, p.stock, p.has_recipe
ORDER BY p.id;
" 2>/dev/null

echo ""
echo "📦 CEK BAHAN BAKU:"
echo "------------------"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    id,
    name AS bahan_baku,
    stock AS stok,
    unit,
    updated_at AS terakhir_update
FROM materials
ORDER BY updated_at DESC;
" 2>/dev/null

echo ""
echo "🧾 CEK RESEP DETAIL:"
echo "--------------------"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    p.name AS produk,
    m.name AS bahan_baku,
    r.quantity_used AS jumlah_per_porsi,
    m.unit,
    m.stock AS stok_tersedia,
    FLOOR(m.stock / r.quantity_used) AS bisa_buat
FROM recipes r
JOIN products p ON r.product_id = p.id
JOIN materials m ON r.material_id = m.id
ORDER BY p.name, m.name;
" 2>/dev/null

echo ""
echo "💰 CEK TRANSAKSI TERAKHIR:"
echo "--------------------------"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    t.id,
    t.total_amount,
    t.cashier_name,
    t.created_at,
    GROUP_CONCAT(CONCAT(td.product_name, ' (', td.qty, 'x)') SEPARATOR ', ') AS items
FROM transactions t
LEFT JOIN transaction_details td ON t.id = td.transaction_id
GROUP BY t.id, t.total_amount, t.cashier_name, t.created_at
ORDER BY t.created_at DESC
LIMIT 5;
" 2>/dev/null

echo ""
echo "🔍 CEK PRODUK DENGAN RESEP TAPI FLAG SALAH:"
echo "--------------------------------------------"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    p.id,
    p.name,
    p.has_recipe AS flag_has_recipe,
    COUNT(r.id) AS actual_recipe_count,
    CASE 
        WHEN p.has_recipe = 1 AND COUNT(r.id) > 0 THEN '✅ OK'
        WHEN p.has_recipe = 0 AND COUNT(r.id) = 0 THEN '✅ OK'
        ELSE '❌ SALAH'
    END AS status
FROM products p
LEFT JOIN recipes r ON p.id = r.product_id
GROUP BY p.id, p.name, p.has_recipe
HAVING status = '❌ SALAH';
" 2>/dev/null

echo ""
echo "📋 INSTRUKSI TESTING:"
echo "---------------------"
echo "1. Catat stok bahan baku SEBELUM transaksi"
echo "2. Lakukan transaksi di kasir (beli produk dengan resep)"
echo "3. Jalankan script ini lagi: ./verify-stock.sh"
echo "4. Bandingkan stok SEBELUM dan SESUDAH"
echo ""
echo "Expected: Stok bahan baku HARUS berkurang!"
echo ""
