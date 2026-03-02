#!/bin/bash

echo "🧪 COMPREHENSIVE POS UMKM FEATURE TEST"
echo "======================================"

BASE_URL="http://localhost:8082/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0

test_endpoint() {
    local name="$1"
    local url="$2"
    local method="${3:-GET}"
    local data="$4"
    local expected_status="${5:-200}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Testing $name... "
    
    if [ "$method" = "POST" ] && [ -n "$data" ]; then
        response=$(curl -s -w "%{http_code}" -X POST "$url" -H "Content-Type: application/json" -d "$data")
    else
        response=$(curl -s -w "%{http_code}" "$url")
    fi
    
    status_code="${response: -3}"
    body="${response%???}"
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL (Status: $status_code)${NC}"
        return 1
    fi
}

echo ""
echo "🔍 BACKEND API TESTS"
echo "===================="

# 1. Health Check
test_endpoint "Health Check" "$BASE_URL/../health"

# 2. Authentication
test_endpoint "Admin Login" "$BASE_URL/auth/login" "POST" '{"username":"admin","password":"admin123"}'
test_endpoint "Kasir Login" "$BASE_URL/auth/login" "POST" '{"username":"kasir","password":"kasir123"}'
test_endpoint "Invalid Login" "$BASE_URL/auth/login" "POST" '{"username":"invalid","password":"wrong"}' "401"

# 3. Products
test_endpoint "Get All Products" "$BASE_URL/products"
test_endpoint "Get Product by ID" "$BASE_URL/products/1"
test_endpoint "Get Product Recipes" "$BASE_URL/products/1/recipes"

# 4. Materials
test_endpoint "Get All Materials" "$BASE_URL/materials"
test_endpoint "Get Low Stock Materials" "$BASE_URL/materials/low-stock"

# 5. Recipes
test_endpoint "Get Recipes by Product" "$BASE_URL/recipes/product/1"

# 6. Transactions
test_endpoint "Get All Transactions" "$BASE_URL/transactions"
test_endpoint "Get Daily Report" "$BASE_URL/transactions/report/daily"
test_endpoint "Get Monthly Report" "$BASE_URL/transactions/report/monthly"

# 7. Dashboard
test_endpoint "Dashboard Summary" "$BASE_URL/dashboard/summary"
test_endpoint "Top Products" "$BASE_URL/dashboard/top-products"
test_endpoint "Sales Trend" "$BASE_URL/dashboard/sales-trend"

echo ""
echo "📊 TEST RESULTS"
echo "==============="
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
else
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
fi

echo ""
echo "🌐 FRONTEND MANUAL TEST CHECKLIST"
echo "================================="
echo "Open browser: http://localhost:3000"
echo ""
echo "Login Credentials:"
echo "  Admin: admin / admin123"
echo "  Kasir: kasir / kasir123"
echo ""
echo "Test these features manually:"
echo "□ Login page works"
echo "□ Dashboard loads with data"
echo "□ Products page shows products list"
echo "□ Add/Edit/Delete products (Admin only)"
echo "□ Materials page shows materials list"
echo "□ Add/Edit materials (Admin only)"
echo "□ Kasir/POS page for transactions"
echo "□ Add products to cart"
echo "□ Process payment"
echo "□ Print receipt"
echo "□ Transactions history page"
echo "□ Daily/Monthly reports"
echo "□ Settings page"
echo "□ Theme switching (Dark/Light)"
echo "□ Logout functionality"
echo ""
echo "🚀 Ready for testing!"
