#!/bin/bash

echo "🔍 COMPREHENSIVE CRUD TESTING - ALL MODULES"
echo "==========================================="

BASE_URL="http://localhost:8082/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test function
run_test() {
    local test_name="$1"
    local expected_success="$2"
    local response="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    local success=$(echo "$response" | jq -r '.success // false')
    
    if [ "$success" = "$expected_success" ]; then
        echo -e "${GREEN}✅ $test_name${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ $test_name${NC}"
        echo "   Expected: $expected_success, Got: $success"
        echo "   Response: $(echo "$response" | jq -r '.message // "No message"')"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Get tokens
echo "🔐 Getting authentication tokens..."
ADMIN_LOGIN=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}')
ADMIN_TOKEN=$(echo $ADMIN_LOGIN | jq -r '.data.token')
run_test "Admin Login" "true" "$ADMIN_LOGIN"

KASIR_LOGIN=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"kasir","password":"kasir123"}')
KASIR_TOKEN=$(echo $KASIR_LOGIN | jq -r '.data.token')
run_test "Kasir Login" "true" "$KASIR_LOGIN"

echo ""
echo "📦 MATERIALS CRUD TESTING"
echo "========================="

# Materials CREATE
echo "➤ Testing Materials CREATE..."
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Test Material 1","unit":"gram","stock":1000,"min_stock":100,"cost_per_unit":25}')
run_test "Materials CREATE (Admin)" "true" "$RESPONSE"
MATERIAL_ID=$(echo $RESPONSE | jq '.data.id')

# Materials CREATE - Invalid data
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"","unit":"","stock":-1}')
run_test "Materials CREATE (Invalid data)" "false" "$RESPONSE"

# Materials CREATE - Kasir (should fail)
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer $KASIR_TOKEN" -H "Content-Type: application/json" -d '{"name":"Unauthorized","unit":"gram","stock":10,"min_stock":1,"cost_per_unit":5}')
run_test "Materials CREATE (Kasir - should fail)" "false" "$RESPONSE"

# Materials CREATE - No token
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Content-Type: application/json" -d '{"name":"No token","unit":"gram","stock":10,"min_stock":1,"cost_per_unit":5}')
run_test "Materials CREATE (No token)" "false" "$RESPONSE"

# Materials READ ALL
RESPONSE=$(curl -s "$BASE_URL/materials")
run_test "Materials READ ALL" "true" "$RESPONSE"

# Materials READ with pagination
RESPONSE=$(curl -s "$BASE_URL/materials?page=1&limit=5")
run_test "Materials READ (Pagination)" "true" "$RESPONSE"

# Materials UPDATE
RESPONSE=$(curl -s "$BASE_URL/materials/$MATERIAL_ID" -X PUT -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Updated Material 1","unit":"kg","stock":2000,"min_stock":200,"cost_per_unit":50,"supplier":"Test Supplier"}')
run_test "Materials UPDATE (Admin)" "true" "$RESPONSE"

# Materials UPDATE - Kasir (should fail)
RESPONSE=$(curl -s "$BASE_URL/materials/$MATERIAL_ID" -X PUT -H "Authorization: Bearer $KASIR_TOKEN" -H "Content-Type: application/json" -d '{"name":"Unauthorized Update","unit":"gram","stock":100,"min_stock":10,"cost_per_unit":25}')
run_test "Materials UPDATE (Kasir - should fail)" "false" "$RESPONSE"

# Materials UPDATE - Non-existent
RESPONSE=$(curl -s "$BASE_URL/materials/99999" -X PUT -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Non-existent","unit":"gram","stock":100,"min_stock":10,"cost_per_unit":25}')
run_test "Materials UPDATE (Non-existent)" "false" "$RESPONSE"

# Materials LOW STOCK
RESPONSE=$(curl -s "$BASE_URL/materials/low-stock")
run_test "Materials LOW STOCK" "true" "$RESPONSE"

echo ""
echo "🛍️ PRODUCTS CRUD TESTING"
echo "========================"

# Products CREATE
echo "➤ Testing Products CREATE..."
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Test Product 1","category":"Test Category","selling_price":20000,"cost_price":10000,"stock":50,"description":"Test product description"}')
run_test "Products CREATE (Admin)" "true" "$RESPONSE"
PRODUCT_ID=$(echo $RESPONSE | jq '.data.id')

# Products CREATE - Invalid data
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"","category":"","selling_price":-1,"cost_price":-1,"stock":-1}')
run_test "Products CREATE (Invalid data)" "false" "$RESPONSE"

# Products CREATE - Kasir (should fail)
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $KASIR_TOKEN" -H "Content-Type: application/json" -d '{"name":"Unauthorized Product","category":"Test","selling_price":10000,"cost_price":5000,"stock":10}')
run_test "Products CREATE (Kasir - should fail)" "false" "$RESPONSE"

# Products READ ALL
RESPONSE=$(curl -s "$BASE_URL/products")
run_test "Products READ ALL" "true" "$RESPONSE"

# Products READ with pagination
RESPONSE=$(curl -s "$BASE_URL/products?page=1&limit=5")
run_test "Products READ (Pagination)" "true" "$RESPONSE"

# Products READ SINGLE
RESPONSE=$(curl -s "$BASE_URL/products/$PRODUCT_ID")
run_test "Products READ SINGLE" "true" "$RESPONSE"

# Products READ SINGLE - Non-existent
RESPONSE=$(curl -s "$BASE_URL/products/99999")
run_test "Products READ SINGLE (Non-existent)" "false" "$RESPONSE"

# Products UPDATE
RESPONSE=$(curl -s "$BASE_URL/products/$PRODUCT_ID" -X PUT -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Updated Product 1","category":"Updated Category","selling_price":25000,"cost_price":12000,"stock":60,"description":"Updated description"}')
run_test "Products UPDATE (Admin)" "true" "$RESPONSE"

# Products UPDATE - Kasir (should fail)
RESPONSE=$(curl -s "$BASE_URL/products/$PRODUCT_ID" -X PUT -H "Authorization: Bearer $KASIR_TOKEN" -H "Content-Type: application/json" -d '{"name":"Unauthorized Update","category":"Test","selling_price":15000,"cost_price":7000,"stock":20}')
run_test "Products UPDATE (Kasir - should fail)" "false" "$RESPONSE"

# Products GET RECIPES
RESPONSE=$(curl -s "$BASE_URL/products/$PRODUCT_ID/recipes")
run_test "Products GET RECIPES" "true" "$RESPONSE"

echo ""
echo "🍳 RECIPES CRUD TESTING"
echo "======================"

# Setup additional materials for recipes
echo "➤ Setting up additional materials for recipes..."
MATERIAL2_RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Recipe Material 2","unit":"ml","stock":2000,"min_stock":200,"cost_per_unit":15}')
MATERIAL2_ID=$(echo $MATERIAL2_RESPONSE | jq '.data.id')

# Recipes CREATE
echo "➤ Testing Recipes CREATE..."
RESPONSE=$(curl -s "$BASE_URL/recipes" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d "{\"product_id\":$PRODUCT_ID,\"recipes\":[{\"material_id\":$MATERIAL_ID,\"quantity_used\":30},{\"material_id\":$MATERIAL2_ID,\"quantity_used\":200}]}")
run_test "Recipes CREATE (Admin)" "true" "$RESPONSE"

# Recipes CREATE - Invalid product
RESPONSE=$(curl -s "$BASE_URL/recipes" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"product_id":99999,"recipes":[{"material_id":1,"quantity_used":10}]}')
run_test "Recipes CREATE (Invalid product)" "false" "$RESPONSE"

# Recipes CREATE - Kasir (should fail)
RESPONSE=$(curl -s "$BASE_URL/recipes" -X POST -H "Authorization: Bearer $KASIR_TOKEN" -H "Content-Type: application/json" -d "{\"product_id\":$PRODUCT_ID,\"recipes\":[{\"material_id\":$MATERIAL_ID,\"quantity_used\":25}]}")
run_test "Recipes CREATE (Kasir - should fail)" "false" "$RESPONSE"

# Recipes READ
RESPONSE=$(curl -s "$BASE_URL/recipes/product/$PRODUCT_ID")
run_test "Recipes READ" "true" "$RESPONSE"
RECIPE_ID=$(echo $RESPONSE | jq '.data[0].id')

# Recipes READ - Non-existent product
RESPONSE=$(curl -s "$BASE_URL/recipes/product/99999")
run_test "Recipes READ (Non-existent product)" "true" "$RESPONSE"

# Recipes UPDATE (replace existing)
RESPONSE=$(curl -s "$BASE_URL/recipes" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d "{\"product_id\":$PRODUCT_ID,\"recipes\":[{\"material_id\":$MATERIAL_ID,\"quantity_used\":50},{\"material_id\":$MATERIAL2_ID,\"quantity_used\":300}]}")
run_test "Recipes UPDATE (Replace)" "true" "$RESPONSE"

# Recipes DELETE individual
UPDATED_RECIPES=$(curl -s "$BASE_URL/recipes/product/$PRODUCT_ID")
RECIPE_TO_DELETE=$(echo $UPDATED_RECIPES | jq '.data[0].id')
RESPONSE=$(curl -s "$BASE_URL/recipes/$RECIPE_TO_DELETE" -X DELETE -H "Authorization: Bearer $ADMIN_TOKEN")
run_test "Recipes DELETE (Admin)" "true" "$RESPONSE"

# Recipes DELETE - Kasir (should fail)
REMAINING_RECIPE=$(curl -s "$BASE_URL/recipes/product/$PRODUCT_ID" | jq '.data[0].id')
RESPONSE=$(curl -s "$BASE_URL/recipes/$REMAINING_RECIPE" -X DELETE -H "Authorization: Bearer $KASIR_TOKEN")
run_test "Recipes DELETE (Kasir - should fail)" "false" "$RESPONSE"

echo ""
echo "💰 TRANSACTIONS CRUD TESTING"
echo "============================"

# Transactions CREATE
echo "➤ Testing Transactions CREATE..."
RESPONSE=$(curl -s "$BASE_URL/transactions" -X POST -H "Content-Type: application/json" -d "{\"items\":[{\"product_id\":$PRODUCT_ID,\"quantity\":2}],\"cash_received\":60000,\"payment_method\":\"CASH\",\"cashier_name\":\"Test Kasir\",\"notes\":\"CRUD test transaction\"}")
run_test "Transactions CREATE" "true" "$RESPONSE"
TRANSACTION_ID=$(echo $RESPONSE | jq '.data.transaction.id')

# Transactions CREATE - Invalid data
RESPONSE=$(curl -s "$BASE_URL/transactions" -X POST -H "Content-Type: application/json" -d '{"items":[],"cash_received":0,"payment_method":"","cashier_name":"","notes":""}')
run_test "Transactions CREATE (Invalid data)" "false" "$RESPONSE"

# Transactions CREATE - Insufficient stock
RESPONSE=$(curl -s "$BASE_URL/transactions" -X POST -H "Content-Type: application/json" -d "{\"items\":[{\"product_id\":$PRODUCT_ID,\"quantity\":1000}],\"cash_received\":1000000,\"payment_method\":\"CASH\",\"cashier_name\":\"Test Kasir\",\"notes\":\"Stock test\"}")
run_test "Transactions CREATE (Insufficient stock)" "false" "$RESPONSE"

# Transactions CREATE - Insufficient cash
RESPONSE=$(curl -s "$BASE_URL/transactions" -X POST -H "Content-Type: application/json" -d "{\"items\":[{\"product_id\":$PRODUCT_ID,\"quantity\":1}],\"cash_received\":1000,\"payment_method\":\"CASH\",\"cashier_name\":\"Test Kasir\",\"notes\":\"Cash test\"}")
run_test "Transactions CREATE (Insufficient cash)" "false" "$RESPONSE"

# Transactions READ ALL
RESPONSE=$(curl -s "$BASE_URL/transactions")
run_test "Transactions READ ALL" "true" "$RESPONSE"

# Transactions READ with pagination
RESPONSE=$(curl -s "$BASE_URL/transactions?page=1&limit=5")
run_test "Transactions READ (Pagination)" "true" "$RESPONSE"

# Transactions READ SINGLE
RESPONSE=$(curl -s "$BASE_URL/transactions/$TRANSACTION_ID")
run_test "Transactions READ SINGLE" "true" "$RESPONSE"

# Transactions READ SINGLE - Non-existent
RESPONSE=$(curl -s "$BASE_URL/transactions/99999")
run_test "Transactions READ SINGLE (Non-existent)" "false" "$RESPONSE"

# Transactions RECEIPT
RESPONSE=$(curl -s "$BASE_URL/transactions/$TRANSACTION_ID/receipt")
run_test "Transactions RECEIPT" "true" "$RESPONSE"

# Transactions RECEIPT - Non-existent
RESPONSE=$(curl -s "$BASE_URL/transactions/99999/receipt")
run_test "Transactions RECEIPT (Non-existent)" "false" "$RESPONSE"

echo ""
echo "📊 REPORTS & DASHBOARD TESTING"
echo "=============================="

# Dashboard Summary
RESPONSE=$(curl -s "$BASE_URL/dashboard/summary")
run_test "Dashboard Summary" "true" "$RESPONSE"

# Top Products
RESPONSE=$(curl -s "$BASE_URL/dashboard/top-products")
run_test "Dashboard Top Products" "true" "$RESPONSE"

# Top Products with limit
RESPONSE=$(curl -s "$BASE_URL/dashboard/top-products?limit=3")
run_test "Dashboard Top Products (Limited)" "true" "$RESPONSE"

# Sales Trend
RESPONSE=$(curl -s "$BASE_URL/dashboard/sales-trend")
run_test "Dashboard Sales Trend" "true" "$RESPONSE"

# Sales Trend with days
RESPONSE=$(curl -s "$BASE_URL/dashboard/sales-trend?days=7")
run_test "Dashboard Sales Trend (7 days)" "true" "$RESPONSE"

# Daily Report
TODAY=$(date +%Y-%m-%d)
RESPONSE=$(curl -s "$BASE_URL/transactions/report/daily?date=$TODAY")
run_test "Daily Report (Today)" "true" "$RESPONSE"

# Daily Report - Specific date
RESPONSE=$(curl -s "$BASE_URL/transactions/report/daily?date=2026-01-20")
run_test "Daily Report (Specific date)" "true" "$RESPONSE"

# Monthly Report
MONTH=$(date +%Y-%m)
RESPONSE=$(curl -s "$BASE_URL/transactions/report/monthly?month=$MONTH")
run_test "Monthly Report (Current)" "true" "$RESPONSE"

# Monthly Report - Specific month
RESPONSE=$(curl -s "$BASE_URL/transactions/report/monthly?month=2026-01")
run_test "Monthly Report (Specific month)" "true" "$RESPONSE"

echo ""
echo "🏭 PRODUCTION TESTING"
echo "===================="

# Production Cost Calculation
RESPONSE=$(curl -s "$BASE_URL/production/calculate-cost/$PRODUCT_ID" -X POST -H "Authorization: Bearer $ADMIN_TOKEN")
run_test "Production Cost Calculation" "true" "$RESPONSE"

# Production Cost - Non-existent product
RESPONSE=$(curl -s "$BASE_URL/production/calculate-cost/99999" -X POST -H "Authorization: Bearer $ADMIN_TOKEN")
run_test "Production Cost (Non-existent)" "false" "$RESPONSE"

# Production Cost - Kasir (should fail)
RESPONSE=$(curl -s "$BASE_URL/production/calculate-cost/$PRODUCT_ID" -X POST -H "Authorization: Bearer $KASIR_TOKEN")
run_test "Production Cost (Kasir - should fail)" "false" "$RESPONSE"

echo ""
echo "🔐 AUTHENTICATION TESTING"
echo "========================="

# Valid Login
RESPONSE=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}')
run_test "Valid Admin Login" "true" "$RESPONSE"

RESPONSE=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"kasir","password":"kasir123"}')
run_test "Valid Kasir Login" "true" "$RESPONSE"

# Invalid Login
RESPONSE=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"invalid","password":"wrong"}')
run_test "Invalid Login" "false" "$RESPONSE"

# Empty credentials
RESPONSE=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"","password":""}')
run_test "Empty Credentials" "false" "$RESPONSE"

# Token validation
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Token Test","unit":"gram","stock":10,"min_stock":1,"cost_per_unit":5}')
run_test "Valid Token Access" "true" "$RESPONSE"

# Invalid token
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer invalid_token" -H "Content-Type: application/json" -d '{"name":"Invalid Token","unit":"gram","stock":10,"min_stock":1,"cost_per_unit":5}')
run_test "Invalid Token Access" "false" "$RESPONSE"

echo ""
echo "🧹 CLEANUP TEST DATA"
echo "===================="

# Delete test materials
RESPONSE=$(curl -s "$BASE_URL/materials/$MATERIAL_ID" -X DELETE -H "Authorization: Bearer $ADMIN_TOKEN")
run_test "Cleanup Material 1" "true" "$RESPONSE"

RESPONSE=$(curl -s "$BASE_URL/materials/$MATERIAL2_ID" -X DELETE -H "Authorization: Bearer $ADMIN_TOKEN")
run_test "Cleanup Material 2" "true" "$RESPONSE"

# Delete test product
RESPONSE=$(curl -s "$BASE_URL/products/$PRODUCT_ID" -X DELETE -H "Authorization: Bearer $ADMIN_TOKEN")
run_test "Cleanup Product" "true" "$RESPONSE"

echo ""
echo "🎯 COMPREHENSIVE TEST RESULTS"
echo "============================="
echo -e "Total Tests: ${YELLOW}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}🌟 ALL TESTS PASSED! SYSTEM IS FULLY FUNCTIONAL${NC}"
else
    echo -e "\n${RED}❌ $FAILED_TESTS TESTS FAILED - REVIEW REQUIRED${NC}"
fi

echo ""
echo "📋 TESTED MODULES:"
echo "=================="
echo "✅ Materials CRUD (CREATE, READ, UPDATE, DELETE)"
echo "✅ Products CRUD (CREATE, READ, UPDATE, DELETE)"
echo "✅ Recipes CRUD (CREATE, READ, UPDATE, DELETE)"
echo "✅ Transactions CRUD (CREATE, READ, RECEIPT)"
echo "✅ Reports & Dashboard (Summary, Top Products, Sales Trend)"
echo "✅ Production (Cost Calculation)"
echo "✅ Authentication (Login, Token Validation)"
echo "✅ Authorization (Admin vs Kasir permissions)"
echo "✅ Error Handling (Invalid data, Non-existent resources)"
echo "✅ Edge Cases (Empty data, Insufficient stock/cash)"
