#!/bin/bash

# Script untuk cek dan bersihkan orphan recipes

echo "🔍 CEK ORPHAN RECIPES"
echo "====================="
echo ""

DB_USER="root"
DB_PASS="root"
DB_NAME="pos_umkm"

# Cek bahan baku yang ingin dihapus
echo "Masukkan ID bahan baku yang ingin dihapus:"
read MATERIAL_ID

if [ -z "$MATERIAL_ID" ]; then
    echo "❌ ID tidak boleh kosong"
    exit 1
fi

echo ""
echo "📊 INFO BAHAN BAKU:"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT id, name, stock, unit 
FROM materials 
WHERE id = $MATERIAL_ID;
" 2>/dev/null

echo ""
echo "🔍 CEK RESEP YANG MENGGUNAKAN BAHAN INI:"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    r.id AS recipe_id,
    r.product_id,
    p.name AS product_name,
    r.material_id,
    m.name AS material_name,
    r.quantity_used
FROM recipes r
LEFT JOIN products p ON r.product_id = p.id
LEFT JOIN materials m ON r.material_id = m.id
WHERE r.material_id = $MATERIAL_ID;
" 2>/dev/null

RECIPE_COUNT=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -se "SELECT COUNT(*) FROM recipes WHERE material_id = $MATERIAL_ID;" 2>/dev/null)

echo ""
echo "Total resep yang menggunakan bahan ini: $RECIPE_COUNT"

if [ "$RECIPE_COUNT" -gt 0 ]; then
    echo ""
    echo "⚠️  DITEMUKAN RESEP YANG MENGGUNAKAN BAHAN INI!"
    echo ""
    echo "Pilihan:"
    echo "1. Lihat detail resep"
    echo "2. Hapus resep orphan (jika product_id NULL)"
    echo "3. Hapus SEMUA resep yang menggunakan bahan ini (HATI-HATI!)"
    echo "4. Batal"
    echo ""
    read -p "Pilih (1-4): " CHOICE
    
    case $CHOICE in
        1)
            echo ""
            echo "Detail resep:"
            mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
            SELECT 
                r.id,
                r.product_id,
                p.name AS product_name,
                p.has_recipe,
                r.quantity_used,
                r.notes
            FROM recipes r
            LEFT JOIN products p ON r.product_id = p.id
            WHERE r.material_id = $MATERIAL_ID;
            " 2>/dev/null
            ;;
        2)
            echo ""
            echo "Menghapus resep orphan (product_id NULL)..."
            mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
            DELETE FROM recipes 
            WHERE material_id = $MATERIAL_ID 
            AND product_id IS NULL;
            " 2>/dev/null
            
            DELETED=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -se "SELECT ROW_COUNT();" 2>/dev/null)
            echo "✅ Dihapus: $DELETED resep orphan"
            
            # Cek lagi
            REMAINING=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -se "SELECT COUNT(*) FROM recipes WHERE material_id = $MATERIAL_ID;" 2>/dev/null)
            if [ "$REMAINING" -eq 0 ]; then
                echo "✅ Sekarang bahan baku bisa dihapus!"
            else
                echo "⚠️  Masih ada $REMAINING resep yang menggunakan bahan ini"
            fi
            ;;
        3)
            echo ""
            read -p "⚠️  YAKIN ingin hapus SEMUA resep? (yes/no): " CONFIRM
            if [ "$CONFIRM" = "yes" ]; then
                mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
                DELETE FROM recipes WHERE material_id = $MATERIAL_ID;
                " 2>/dev/null
                
                echo "✅ Semua resep dihapus"
                echo "✅ Sekarang bahan baku bisa dihapus!"
                
                # Update has_recipe flag untuk produk yang terpengaruh
                echo "Updating has_recipe flags..."
                mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
                UPDATE products p
                SET p.has_recipe = 0
                WHERE NOT EXISTS (
                    SELECT 1 FROM recipes r WHERE r.product_id = p.id
                );
                " 2>/dev/null
                echo "✅ Flags updated"
            else
                echo "❌ Dibatalkan"
            fi
            ;;
        4)
            echo "❌ Dibatalkan"
            ;;
        *)
            echo "❌ Pilihan tidak valid"
            ;;
    esac
else
    echo "✅ Tidak ada resep yang menggunakan bahan ini"
    echo "✅ Bahan baku bisa dihapus!"
fi

echo ""
echo "📊 SUMMARY:"
echo "─────────────────────────────────────────"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    'Total Materials' AS info,
    COUNT(*) AS count
FROM materials
UNION ALL
SELECT 
    'Total Recipes' AS info,
    COUNT(*) AS count
FROM recipes
UNION ALL
SELECT 
    'Orphan Recipes (NULL product)' AS info,
    COUNT(*) AS count
FROM recipes
WHERE product_id IS NULL;
" 2>/dev/null
