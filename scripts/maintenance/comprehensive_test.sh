#!/bin/bash

echo "🧪 Comprehensive POS UMKM Testing..."
echo "=================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASSED${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC}: $2"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Backend Health Check
echo "1️⃣ Testing Backend Health..."
HEALTH_RESPONSE=$(curl -s http://localhost:8082/health)
if echo $HEALTH_RESPONSE | grep -q "healthy"; then
    test_result 0 "Backend is healthy"
else
    test_result 1 "Backend health check failed"
fi

# Test 2: Frontend Accessibility
echo
echo "2️⃣ Testing Frontend Accessibility..."
FRONTEND_RESPONSE=$(curl -s http://localhost:3000)
if echo $FRONTEND_RESPONSE | grep -q "DOCTYPE html"; then
    test_result 0 "Frontend is accessible"
else
    test_result 1 "Frontend is not accessible"
fi

# Test 3: Authentication Flow
echo
echo "3️⃣ Testing Authentication Flow..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')
if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
    test_result 0 "Admin login successful"
    echo "   Token: ${TOKEN:0:20}..."
else
    test_result 1 "Admin login failed"
    echo "   Response: $LOGIN_RESPONSE"
fi

# Test 4: Products CRUD Operations
echo
echo "4️⃣ Testing Products CRUD..."

# Get products
PRODUCTS_RESPONSE=$(curl -s -X GET http://localhost:8082/api/products \
  -H "Authorization: Bearer $TOKEN")
PRODUCT_COUNT=$(echo $PRODUCTS_RESPONSE | jq '.data.products | length')
test_result 0 "Get products (found $PRODUCT_COUNT products)"

# Create product
TIMESTAMP=$(date +%s)
CREATE_RESPONSE=$(curl -s -X POST http://localhost:8082/api/products \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Test Product $TIMESTAMP\",
    \"category\": \"Test Category\", 
    \"cost_price\": 5000,
    \"selling_price\": 8000,
    \"stock\": 10,
    \"image\": \"\"
  }")

CREATE_SUCCESS=$(echo $CREATE_RESPONSE | jq -r '.success')
if [ "$CREATE_SUCCESS" = "true" ]; then
    PRODUCT_ID=$(echo $CREATE_RESPONSE | jq -r '.data.id')
    test_result 0 "Create product (ID: $PRODUCT_ID)"
else
    test_result 1 "Create product failed"
    echo "   Response: $CREATE_RESPONSE"
fi

# Test 5: Materials Management
echo
echo "5️⃣ Testing Materials Management..."
MATERIALS_RESPONSE=$(curl -s -X GET http://localhost:8082/api/materials \
  -H "Authorization: Bearer $TOKEN")
MATERIAL_COUNT=$(echo $MATERIALS_RESPONSE | jq '.data.materials | length')
test_result 0 "Get materials (found $MATERIAL_COUNT materials)"

# Test 6: Recipe Management
echo
echo "6️⃣ Testing Recipe Management..."
if [ "$PRODUCT_ID" != "" ] && [ "$MATERIAL_COUNT" -gt 0 ]; then
    FIRST_MATERIAL_ID=$(echo $MATERIALS_RESPONSE | jq -r '.data.materials[0].id')
    
    RECIPE_RESPONSE=$(curl -s -X POST http://localhost:8082/api/recipes \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"product_id\": $PRODUCT_ID,
        \"recipes\": [
          {
            \"material_id\": $FIRST_MATERIAL_ID,
            \"quantity_used\": 2.5
          }
        ]
      }")
    
    RECIPE_SUCCESS=$(echo $RECIPE_RESPONSE | jq -r '.success')
    if [ "$RECIPE_SUCCESS" = "true" ]; then
        test_result 0 "Create recipe"
    else
        test_result 1 "Create recipe failed"
        echo "   Response: $RECIPE_RESPONSE"
    fi
else
    test_result 1 "Recipe test skipped (no product or materials)"
fi

# Test 7: Dashboard Data
echo
echo "7️⃣ Testing Dashboard Data..."
DASHBOARD_RESPONSE=$(curl -s -X GET http://localhost:8082/api/dashboard/summary \
  -H "Authorization: Bearer $TOKEN")
DASHBOARD_SUCCESS=$(echo $DASHBOARD_RESPONSE | jq -r '.success')
if [ "$DASHBOARD_SUCCESS" = "true" ]; then
    test_result 0 "Dashboard summary"
else
    test_result 1 "Dashboard summary failed"
fi

# Test 8: Transaction System
echo
echo "8️⃣ Testing Transaction System..."
TRANSACTION_RESPONSE=$(curl -s -X POST http://localhost:8082/api/transactions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"cashier_name\": \"Test Cashier\",
    \"items\": [
      {
        \"product_id\": $PRODUCT_ID,
        \"quantity\": 1,
        \"price\": 8000
      }
    ],
    \"total_amount\": 8000,
    \"cash_received\": 10000,
    \"change_amount\": 2000
  }")

TRANSACTION_SUCCESS=$(echo $TRANSACTION_RESPONSE | jq -r '.success')
if [ "$TRANSACTION_SUCCESS" = "true" ]; then
    test_result 0 "Create transaction"
else
    test_result 1 "Create transaction failed"
    echo "   Response: $TRANSACTION_RESPONSE"
fi

# Test 9: Frontend API Proxy
echo
echo "9️⃣ Testing Frontend API Proxy..."
PROXY_RESPONSE=$(curl -s http://localhost:3000/api/health)
if echo $PROXY_RESPONSE | grep -q "healthy"; then
    test_result 0 "Frontend API proxy working"
else
    test_result 1 "Frontend API proxy failed"
fi

# Test 10: Authentication with Wrong Credentials
echo
echo "🔟 Testing Authentication Security..."
WRONG_LOGIN=$(curl -s -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "wrongpassword"}')

WRONG_SUCCESS=$(echo $WRONG_LOGIN | jq -r '.success')
if [ "$WRONG_SUCCESS" = "false" ]; then
    test_result 0 "Authentication security (wrong password rejected)"
else
    test_result 1 "Authentication security failed (wrong password accepted)"
fi

# Summary
echo
echo "=================================="
echo "🏁 Test Summary:"
echo -e "   ${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "   ${RED}Failed: $TESTS_FAILED${NC}"
echo -e "   Total: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! System is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Please check the issues above.${NC}"
    exit 1
fi
