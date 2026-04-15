#!/bin/bash

# Comprehensive Brutal Testing Script for POS UMKM
# This script will test EVERY feature and endpoint

API_URL="http://localhost:8083"
FRONTEND_URL="http://localhost:3000"
TOKEN=""
ADMIN_TOKEN=""
KASIR_TOKEN=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Array to store failed tests
declare -a FAILED_TEST_DETAILS

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

print_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    echo -e "${RED}       Details: $2${NC}"
    FAILED_TEST_DETAILS+=("$1 - $2")
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

# Test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local description=$5
    local auth_token=$6
    
    print_test "$description"
    
    if [ -n "$auth_token" ]; then
        if [ "$method" == "GET" ]; then
            response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint" \
                -H "Authorization: Bearer $auth_token" \
                -H "Content-Type: application/json")
        else
            response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint" \
                -H "Authorization: Bearer $auth_token" \
                -H "Content-Type: application/json" \
                -d "$data")
        fi
    else
        if [ "$method" == "GET" ]; then
            response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint" \
                -H "Content-Type: application/json")
        else
            response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint" \
                -H "Content-Type: application/json" \
                -d "$data")
        fi
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" == "$expected_status" ]; then
        print_success "$description (Status: $http_code)"
        echo "$body"
        return 0
    else
        print_fail "$description" "Expected status $expected_status, got $http_code. Response: $body"
        return 1
    fi
}

# ============================================
# 1. HEALTH CHECK
# ============================================
print_header "1. TESTING HEALTH CHECK"

test_endpoint "GET" "/health" "" "200" "Health check endpoint"

# ============================================
# 2. AUTHENTICATION TESTS
# ============================================
print_header "2. TESTING AUTHENTICATION"

# Test Admin Login
print_test "Admin Login"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"admin123"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" == "200" ]; then
    ADMIN_TOKEN=$(echo "$body" | jq -r '.data.token')
    if [ -n "$ADMIN_TOKEN" ] && [ "$ADMIN_TOKEN" != "null" ]; then
        print_success "Admin login successful"
        echo "Token: ${ADMIN_TOKEN:0:20}..."
    else
        print_fail "Admin login" "Token not found in response"
    fi
else
    print_fail "Admin login" "Expected 200, got $http_code. Response: $body"
fi

# Test Kasir Login
print_test "Kasir Login"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"kasir","password":"kasir123"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" == "200" ]; then
    KASIR_TOKEN=$(echo "$body" | jq -r '.data.token')
    if [ -n "$KASIR_TOKEN" ] && [ "$KASIR_TOKEN" != "null" ]; then
        print_success "Kasir login successful"
    else
        print_fail "Kasir login" "Token not found in response"
    fi
else
    print_fail "Kasir login" "Expected 200, got $http_code"
fi

# Test Invalid Login
test_endpoint "POST" "/api/auth/login" '{"username":"invalid","password":"wrong"}' "401" "Invalid login should fail"

# ============================================
# 3. PRODUCTS TESTS
# ============================================
print_header "3. TESTING PRODUCTS MANAGEMENT"

# Get all products
test_endpoint "GET" "/api/products" "" "200" "Get all products" "$ADMIN_TOKEN"

# Create new product
PRODUCT_DATA='{"name":"Test Product Brutal","category":"Test","selling_price":50000,"cost_price":30000,"stock":100}'
print_test "Create new product"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/products" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$PRODUCT_DATA")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" == "201" ] || [ "$http_code" == "200" ]; then
    PRODUCT_ID=$(echo "$body" | jq -r '.data.id // .id')
    print_success "Product created with ID: $PRODUCT_ID"
else
    print_fail "Create product" "Expected 201/200, got $http_code. Response: $body"
    PRODUCT_ID=1  # Fallback
fi

# Get product by ID
test_endpoint "GET" "/api/products/$PRODUCT_ID" "" "200" "Get product by ID" "$ADMIN_TOKEN"

# Update product
UPDATE_DATA='{"name":"Updated Test Product","category":"Test","selling_price":60000,"cost_price":35000,"stock":150}'
test_endpoint "PUT" "/api/products/$PRODUCT_ID" "$UPDATE_DATA" "200" "Update product" "$ADMIN_TOKEN"

# Get product recipes
test_endpoint "GET" "/api/products/$PRODUCT_ID/recipes" "" "200" "Get product recipes" "$ADMIN_TOKEN"

# ============================================
# 4. MATERIALS TESTS
# ============================================
print_header "4. TESTING MATERIALS MANAGEMENT"

# Get all materials
test_endpoint "GET" "/api/materials" "" "200" "Get all materials" "$ADMIN_TOKEN"

# Create new material
MATERIAL_DATA='{"name":"Test Material Brutal","unit":"kg","stock":50,"min_stock":10,"price_per_unit":5000}'
print_test "Create new material"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/materials" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$MATERIAL_DATA")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" == "201" ] || [ "$http_code" == "200" ]; then
    MATERIAL_ID=$(echo "$body" | jq -r '.data.id // .id')
    print_success "Material created with ID: $MATERIAL_ID"
else
    print_fail "Create material" "Expected 201/200, got $http_code. Response: $body"
    MATERIAL_ID=1  # Fallback
fi

# Update material
UPDATE_MATERIAL='{"name":"Updated Material","unit":"kg","stock":75,"min_stock":15,"price_per_unit":6000}'
test_endpoint "PUT" "/api/materials/$MATERIAL_ID" "$UPDATE_MATERIAL" "200" "Update material" "$ADMIN_TOKEN"

# Get low stock materials
test_endpoint "GET" "/api/materials/low-stock" "" "200" "Get low stock materials" "$ADMIN_TOKEN"

# ============================================
# 5. RECIPES TESTS
# ============================================
print_header "5. TESTING RECIPES MANAGEMENT"

# Create recipe
RECIPE_DATA="{\"product_id\":$PRODUCT_ID,\"recipes\":[{\"material_id\":$MATERIAL_ID,\"quantity_used\":2.5}]}"
test_endpoint "POST" "/api/recipes" "$RECIPE_DATA" "200" "Create recipe" "$ADMIN_TOKEN"

# Get recipes by product
test_endpoint "GET" "/api/recipes/product/$PRODUCT_ID" "" "200" "Get recipes by product" "$ADMIN_TOKEN"

# ============================================
# 6. TRANSACTIONS TESTS
# ============================================
print_header "6. TESTING TRANSACTIONS"

# Get all transactions
test_endpoint "GET" "/api/transactions" "" "200" "Get all transactions" "$ADMIN_TOKEN"

# Create transaction
TRANSACTION_DATA="{\"payment_method\":\"CASH\",\"cash_received\":150000,\"items\":[{\"product_id\":$PRODUCT_ID,\"quantity\":2,\"price_per_unit\":60000}]}"
print_test "Create transaction"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/transactions" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$TRANSACTION_DATA")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" == "201" ] || [ "$http_code" == "200" ]; then
    TRANSACTION_ID=$(echo "$body" | jq -r '.data.transaction.id // .data.id // .id')
    print_success "Transaction created with ID: $TRANSACTION_ID"
else
    print_fail "Create transaction" "Expected 201/200, got $http_code. Response: $body"
    TRANSACTION_ID=1  # Fallback
fi

# Get transaction by ID
test_endpoint "GET" "/api/transactions/$TRANSACTION_ID" "" "200" "Get transaction by ID" "$ADMIN_TOKEN"

# Get transaction receipt
test_endpoint "GET" "/api/transactions/$TRANSACTION_ID/receipt" "" "200" "Get transaction receipt" "$ADMIN_TOKEN"

# ============================================
# 7. REPORTS TESTS
# ============================================
print_header "7. TESTING REPORTS"

# Daily report
TODAY=$(date +%Y-%m-%d)
test_endpoint "GET" "/api/transactions/report/daily?date=$TODAY" "" "200" "Get daily report" "$ADMIN_TOKEN"

# Monthly report
MONTH=$(date +%Y-%m)
test_endpoint "GET" "/api/transactions/report/monthly?month=$MONTH" "" "200" "Get monthly report" "$ADMIN_TOKEN"

# ============================================
# 8. DASHBOARD TESTS
# ============================================
print_header "8. TESTING DASHBOARD"

# Dashboard summary
test_endpoint "GET" "/api/dashboard/summary" "" "200" "Get dashboard summary" "$ADMIN_TOKEN"

# Top products
test_endpoint "GET" "/api/dashboard/top-products" "" "200" "Get top products" "$ADMIN_TOKEN"

# Sales trend
test_endpoint "GET" "/api/dashboard/sales-trend" "" "200" "Get sales trend" "$ADMIN_TOKEN"

# ============================================
# 9. EXPENSES TESTS
# ============================================
print_header "9. TESTING EXPENSES"

# Get all expenses
test_endpoint "GET" "/api/expenses" "" "200" "Get all expenses" "$ADMIN_TOKEN"

# Create expense
EXPENSE_DATA='{"description":"Test Expense Brutal","amount":100000,"category":"operational","date":"2026-03-02"}'
print_test "Create expense"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/expenses" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$EXPENSE_DATA")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" == "201" ] || [ "$http_code" == "200" ]; then
    EXPENSE_ID=$(echo "$body" | jq -r '.data.id // .id')
    print_success "Expense created with ID: $EXPENSE_ID"
else
    print_fail "Create expense" "Expected 201/200, got $http_code. Response: $body"
fi

# ============================================
# 10. PRODUCTION TESTS
# ============================================
print_header "10. TESTING PRODUCTION"

# Get all productions
test_endpoint "GET" "/api/productions" "" "200" "Get all productions" "$ADMIN_TOKEN"

# Create production
PRODUCTION_DATA="{\"product_id\":$PRODUCT_ID,\"quantity\":10,\"production_date\":\"2026-03-02\"}"
print_test "Create production"
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/productions" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$PRODUCTION_DATA")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" == "201" ] || [ "$http_code" == "200" ]; then
    print_success "Production created"
else
    print_fail "Create production" "Expected 201/200, got $http_code. Response: $body"
fi

# ============================================
# 11. SETTINGS TESTS
# ============================================
print_header "11. TESTING SETTINGS"

# Get settings
test_endpoint "GET" "/api/settings" "" "200" "Get settings" "$ADMIN_TOKEN"

# Update settings
SETTINGS_DATA='{"store_name":"Test Store","store_address":"Test Address","store_phone":"08123456789","tax_rate":10,"currency":"IDR"}'
test_endpoint "PUT" "/api/settings" "$SETTINGS_DATA" "200" "Update settings" "$ADMIN_TOKEN"

# ============================================
# 12. PROFIT ANALYSIS TESTS
# ============================================
print_header "12. TESTING PROFIT ANALYSIS"

# Get profit analysis
test_endpoint "GET" "/api/profit/analysis?start_date=2026-03-01&end_date=2026-03-31" "" "200" "Get profit analysis" "$ADMIN_TOKEN"

# ============================================
# 13. AUTHORIZATION TESTS
# ============================================
print_header "13. TESTING AUTHORIZATION"

# Test kasir access to admin-only endpoints
test_endpoint "GET" "/api/settings" "" "403" "Kasir should not access settings" "$KASIR_TOKEN"

# Test without token
test_endpoint "POST" "/api/products" '{"name":"Test"}' "401" "POST without token should fail" ""

# ============================================
# 14. VALIDATION TESTS
# ============================================
print_header "14. TESTING INPUT VALIDATION"

# Invalid product data
test_endpoint "POST" "/api/products" '{"name":"","price":-100}' "400" "Invalid product data should fail" "$ADMIN_TOKEN"

# Invalid material data
test_endpoint "POST" "/api/materials" '{"name":"","stock":-50}' "400" "Invalid material data should fail" "$ADMIN_TOKEN"

# Invalid transaction data
test_endpoint "POST" "/api/transactions" '{"items":[]}' "400" "Empty transaction should fail" "$ADMIN_TOKEN"

# ============================================
# 15. EDGE CASES TESTS
# ============================================
print_header "15. TESTING EDGE CASES"

# Get non-existent product
test_endpoint "GET" "/api/products/999999" "" "404" "Non-existent product should return 404" "$ADMIN_TOKEN"

# Get non-existent transaction
test_endpoint "GET" "/api/transactions/999999" "" "404" "Non-existent transaction should return 404" "$ADMIN_TOKEN"

# Update non-existent product
test_endpoint "PUT" "/api/products/999999" '{"name":"Test"}' "404" "Update non-existent product should fail" "$ADMIN_TOKEN"

# Delete non-existent product
test_endpoint "DELETE" "/api/products/999999" "" "404" "Delete non-existent product should fail" "$ADMIN_TOKEN"

# ============================================
# 16. CLEANUP - DELETE TEST DATA
# ============================================
print_header "16. CLEANUP TEST DATA"

# Try to delete test product (should fail if used in transaction)
print_test "Try to delete test product (may fail if used)"
if [ -n "$PRODUCT_ID" ] && [ "$PRODUCT_ID" != "null" ]; then
    response=$(curl -s -w "\n%{http_code}" -X DELETE "$API_URL/api/products/$PRODUCT_ID" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" == "200" ]; then
        print_success "Product deleted successfully"
    elif [ "$http_code" == "400" ]; then
        print_success "Product deletion prevented (used in transaction) - correct behavior"
    else
        print_fail "Delete product" "Unexpected status $http_code. Response: $body"
    fi
fi

# Try to delete test material (should fail if used in recipe)
print_test "Try to delete test material (may fail if used)"
if [ -n "$MATERIAL_ID" ] && [ "$MATERIAL_ID" != "null" ]; then
    response=$(curl -s -w "\n%{http_code}" -X DELETE "$API_URL/api/materials/$MATERIAL_ID" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" == "200" ]; then
        print_success "Material deleted successfully"
    elif [ "$http_code" == "400" ]; then
        print_success "Material deletion prevented (used in recipe) - correct behavior"
    else
        print_fail "Delete material" "Unexpected status $http_code. Response: $body"
    fi
fi

# ============================================
# FINAL REPORT
# ============================================
print_header "TESTING COMPLETE - FINAL REPORT"

echo -e "${BLUE}Total Tests:${NC} $TOTAL_TESTS"
echo -e "${GREEN}Passed:${NC} $PASSED_TESTS"
echo -e "${RED}Failed:${NC} $FAILED_TESTS"

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "\n${RED}FAILED TESTS DETAILS:${NC}"
    for detail in "${FAILED_TEST_DETAILS[@]}"; do
        echo -e "${RED}  - $detail${NC}"
    done
    echo -e "\n${RED}⚠️  SYSTEM HAS ISSUES - NEEDS FIXING${NC}"
    exit 1
else
    echo -e "\n${GREEN}✓ ALL TESTS PASSED - SYSTEM IS WORKING PERFECTLY${NC}"
    exit 0
fi
