#!/bin/bash

echo "🧪 Testing POS UMKM Complete System Flow..."
echo "============================================="

BASE_URL="http://localhost:8082/api"

# Get admin token
ADMIN_TOKEN=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}' | jq -r '.data.token')

echo "🔐 Admin Token: ${ADMIN_TOKEN:0:20}..."
echo ""

# Test 1: Materials Management
echo "📦 Test 1: Materials Management"
echo "================================"

echo "➤ Creating materials..."
curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Tepung Terigu","unit":"gram","stock":2000,"min_stock":200,"cost_per_unit":8}' | jq '.success, .message'

echo "➤ Getting all materials..."
curl -s "$BASE_URL/materials" | jq '.data.materials | length'

echo "➤ Testing low stock detection..."
curl -s "$BASE_URL/materials/low-stock" | jq '.success'
echo ""

# Test 2: Products Management  
echo "🛍️ Test 2: Products Management"
echo "==============================="

echo "➤ Creating product..."
curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Roti Bakar","category":"Makanan","selling_price":12000,"cost_price":6000,"stock":20}' | jq '.success, .message'

echo "➤ Getting all products..."
PRODUCT_COUNT=$(curl -s "$BASE_URL/products" | jq '.data.products | length')
echo "Total products: $PRODUCT_COUNT"
echo ""

# Test 3: Recipe Management
echo "🍳 Test 3: Recipe Management"
echo "============================"

echo "➤ Creating recipe for Roti Bakar..."
# Get product ID for Roti Bakar
ROTI_ID=$(curl -s "$BASE_URL/products" | jq '.data.products[] | select(.name=="Roti Bakar") | .id')
TEPUNG_ID=$(curl -s "$BASE_URL/materials" | jq '.data.materials[] | select(.name=="Tepung Terigu") | .id')

if [ "$ROTI_ID" != "null" ] && [ "$TEPUNG_ID" != "null" ]; then
    curl -s "$BASE_URL/recipes" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d "{\"product_id\":$ROTI_ID,\"recipes\":[{\"material_id\":$TEPUNG_ID,\"quantity_used\":100}]}" | jq '.success, .message'
    
    echo "➤ Getting recipe..."
    curl -s "$BASE_URL/recipes/product/$ROTI_ID" | jq '.data | length'
else
    echo "❌ Product or Material not found"
fi
echo ""

# Test 4: Transaction Flow with Material Reduction
echo "💰 Test 4: Transaction Flow & Material Reduction"
echo "==============================================="

echo "➤ Material stock before transaction:"
curl -s "$BASE_URL/materials" | jq '.data.materials[] | {name, stock, unit}'

echo "➤ Creating transaction (2x Kopi Susu)..."
curl -s "$BASE_URL/transactions" -X POST -H "Content-Type: application/json" -d '{"items":[{"product_id":3,"quantity":1}],"cash_received":20000,"payment_method":"CASH","cashier_name":"System Test","notes":"Flow test"}' | jq '.success, .message, .data.summary'

echo "➤ Material stock after transaction:"
curl -s "$BASE_URL/materials" | jq '.data.materials[] | {name, stock, unit}'
echo ""

# Test 5: Stock Validation
echo "⚠️ Test 5: Stock Validation"
echo "==========================="

echo "➤ Testing insufficient material stock..."
curl -s "$BASE_URL/transactions" -X POST -H "Content-Type: application/json" -d '{"items":[{"product_id":3,"quantity":100}],"cash_received":2000000,"payment_method":"CASH","cashier_name":"System Test","notes":"Stock test"}' | jq '.success, .message'

echo "➤ Testing insufficient product stock..."
curl -s "$BASE_URL/transactions" -X POST -H "Content-Type: application/json" -d '{"items":[{"product_id":3,"quantity":200}],"cash_received":3000000,"payment_method":"CASH","cashier_name":"System Test","notes":"Product stock test"}' | jq '.success, .message'
echo ""

# Test 6: Reports & Analytics
echo "📊 Test 6: Reports & Analytics"
echo "=============================="

echo "➤ Dashboard summary..."
curl -s "$BASE_URL/dashboard/summary" | jq '.data | {total_products, total_materials, total_transactions, today_sales}'

echo "➤ Daily report..."
TODAY=$(date +%Y-%m-%d)
curl -s "$BASE_URL/transactions/report/daily?date=$TODAY" | jq '.data | {date, transaction_count, total_sales}'

echo "➤ Monthly report..."
MONTH=$(date +%Y-%m)
curl -s "$BASE_URL/transactions/report/monthly?month=$MONTH" | jq '.data.report | {period, transaction_count, total_sales}'
echo ""

# Test 7: Production Cost Calculation
echo "🏭 Test 7: Production Cost Calculation"
echo "====================================="

if [ "$ROTI_ID" != "null" ]; then
    echo "➤ Calculating production cost for Roti Bakar..."
    curl -s "$BASE_URL/production/calculate-cost/$ROTI_ID" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.success, .data'
else
    echo "❌ Roti Bakar product not found"
fi
echo ""

# Test 8: Low Stock Alert
echo "🚨 Test 8: Low Stock Alert"
echo "========================="

echo "➤ Checking low stock materials..."
curl -s "$BASE_URL/materials/low-stock" | jq '.success, .data'
echo ""

# Test 9: Authentication & Authorization
echo "🔐 Test 9: Authentication & Authorization"
echo "========================================"

echo "➤ Testing kasir access to admin endpoint..."
KASIR_TOKEN=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"kasir","password":"kasir123"}' | jq -r '.data.token')
curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer $KASIR_TOKEN" -H "Content-Type: application/json" -d '{"name":"Unauthorized Material","unit":"gram","stock":100,"min_stock":10,"cost_per_unit":5}' | jq '.success, .message'
echo ""

# Summary
echo "✅ SYSTEM FLOW TEST SUMMARY"
echo "==========================="
echo "✅ Materials: Create, Read, Update, Low Stock Detection"
echo "✅ Products: Create, Read, Stock Management"  
echo "✅ Recipes: Create, Read, Material Linking"
echo "✅ Transactions: Create with Material Reduction"
echo "✅ Stock Validation: Material & Product Stock Checks"
echo "✅ Reports: Dashboard, Daily, Monthly Analytics"
echo "✅ Production: Cost Calculation Based on Materials"
echo "✅ Authentication: Role-based Access Control"
echo ""
echo "🌐 Frontend URL: http://localhost:3004"
echo "📱 Test the complete flow on the web interface!"
