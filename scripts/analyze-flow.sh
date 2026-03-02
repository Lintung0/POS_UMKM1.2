#!/bin/bash

echo "🔍 ANALISIS FLOW BAHAN BAKU & PRODUK"
echo "===================================="

echo ""
echo "📊 STRUKTUR DATA SAAT INI:"
echo "========================="

mysql -u jarvis -pjarvis160309 pos_umkm -e "
SELECT 'PRODUCTS' as table_name;
SELECT id, name, cost_price, selling_price, stock, category FROM products LIMIT 5;

SELECT 'RAW MATERIALS' as table_name;
SELECT id, name, stock, unit, price_per_unit, min_stock FROM raw_materials LIMIT 5;

SELECT 'RECIPES' as table_name;
SELECT r.id, p.name as product_name, rm.name as material_name, r.quantity_used, rm.unit 
FROM recipes r 
JOIN products p ON r.product_id = p.id 
JOIN raw_materials rm ON r.material_id = rm.id 
LIMIT 5;
" 2>/dev/null

echo ""
echo "🔄 FLOW ANALYSIS:"
echo "================"

echo "✅ 1. BAHAN BAKU (Raw Materials):"
echo "   - Memiliki stok dalam decimal (untuk gram, ml, dll)"
echo "   - Ada unit satuan (gr, ml, pcs, dll)"
echo "   - Ada harga per unit"
echo "   - Ada minimum stock untuk alert"
echo "   - Ada supplier info"

echo ""
echo "✅ 2. RESEP (Recipes):"
echo "   - Menghubungkan produk dengan bahan baku"
echo "   - Quantity_used menentukan berapa bahan dibutuhkan per produk"
echo "   - Mendukung multiple bahan per produk"

echo ""
echo "✅ 3. PRODUK (Products):"
echo "   - Memiliki cost_price (harga modal)"
echo "   - Memiliki selling_price (harga jual)"
echo "   - Stock dalam integer (unit produk jadi)"
echo "   - Profit = selling_price - cost_price"

echo ""
echo "✅ 4. TRANSAKSI (Transactions):"
echo "   - Cek stok produk sebelum jual"
echo "   - Cek stok bahan baku berdasarkan resep"
echo "   - Kurangi stok bahan baku otomatis"
echo "   - Kurangi stok produk"
echo "   - Hitung profit per transaksi"

echo ""
echo "🎯 REKOMENDASI PERBAIKAN:"
echo "======================="

echo "❌ MASALAH YANG DITEMUKAN:"
echo "1. Cost calculation tidak otomatis dari bahan baku"
echo "2. Tidak ada production/manufacturing process"
echo "3. Stok produk manual, tidak auto-calculate dari bahan"

echo ""
echo "✅ SOLUSI YANG DISARANKAN:"
echo "1. Auto-calculate cost_price dari total bahan baku"
echo "2. Tambah fitur produksi untuk convert bahan jadi produk"
echo "3. Tambah alert low stock untuk bahan baku"
