#!/bin/bash

echo "📊 POS UMKM DATABASE VIEWER"
echo "=========================="

BASE_URL="http://localhost:8082/api"

echo "1️⃣ MATERIALS (Bahan Baku)"
echo "========================="
curl -s "$BASE_URL/materials" | jq '.data.materials[] | {id, name, stock, unit, price_per_unit, supplier}'

echo ""
echo "2️⃣ PRODUCTS (Produk)"
echo "==================="
curl -s "$BASE_URL/products" | jq '.data.products[] | {id, name, category, cost_price, selling_price, stock}'

echo ""
echo "3️⃣ TRANSACTIONS (Transaksi)"
echo "=========================="
curl -s "$BASE_URL/transactions" | jq '.data.transactions[] | {id, total_amount, payment_method, cashier_name, created_at}'

echo ""
echo "4️⃣ DASHBOARD SUMMARY"
echo "==================="
curl -s "$BASE_URL/dashboard/summary" | jq '.data'

echo ""
echo "🔗 DATABASE ACCESS OPTIONS:"
echo "=========================="
echo "1. Web Interface: http://localhost:8081"
echo "   Username: pos_user"
echo "   Password: pos_password"
echo ""
echo "2. Command Line:"
echo "   docker exec -it pos-mysql mysql -upos_user -ppos_password pos_umkm"
echo ""
echo "3. MySQL Client:"
echo "   mysql -h localhost -P 3307 -u pos_user -ppos_password pos_umkm"
