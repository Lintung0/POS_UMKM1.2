#!/bin/bash

echo "🔍 DEBUGGING 400 ERRORS ON PRODUCTS"
echo "==================================="

BASE_URL="http://localhost:8082/api"

# Get admin token
ADMIN_TOKEN=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}' | jq -r '.data.token')

echo "🔐 Admin token obtained"
echo ""

echo "1️⃣ Testing Valid Product Creation"
echo "================================="

VALID_PRODUCT=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Valid Product","category":"Test","selling_price":15000,"cost_price":8000,"stock":20,"description":"Valid product"}')
echo "Valid product: $(echo $VALID_PRODUCT | jq '{success, message}')"

echo ""
echo "2️⃣ Testing Invalid Data Scenarios"
echo "================================="

echo "➤ Empty name..."
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"","category":"Test","selling_price":10000,"cost_price":5000,"stock":10}')
echo "Empty name: $(echo $RESPONSE | jq '{success, message}')"

echo "➤ Negative prices..."
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Test Product","category":"Test","selling_price":-1,"cost_price":-1,"stock":10}')
echo "Negative prices: $(echo $RESPONSE | jq '{success, message}')"

echo "➤ Missing required fields..."
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"category":"Test"}')
echo "Missing fields: $(echo $RESPONSE | jq '{success, message}')"

echo "➤ Invalid JSON..."
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Test","invalid_json":}')
echo "Invalid JSON: $(echo $RESPONSE | jq '{success, message}')"

echo "➤ Zero values..."
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Zero Product","category":"Test","selling_price":0,"cost_price":0,"stock":0}')
echo "Zero values: $(echo $RESPONSE | jq '{success, message}')"

echo ""
echo "3️⃣ Testing Frontend-like Requests"
echo "================================="

echo "➤ Request with CORS headers..."
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Origin: http://localhost:3008" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"CORS Product","category":"Test","selling_price":12000,"cost_price":6000,"stock":15}')
echo "CORS request: $(echo $RESPONSE | jq '{success, message}')"

echo "➤ Request without authorization..."
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Content-Type: application/json" -d '{"name":"No Auth Product","category":"Test","selling_price":10000,"cost_price":5000,"stock":10}')
echo "No auth: $(echo $RESPONSE | jq '{success, message}')"

echo "➤ Request with invalid token..."
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer invalid_token" -H "Content-Type: application/json" -d '{"name":"Invalid Token Product","category":"Test","selling_price":10000,"cost_price":5000,"stock":10}')
echo "Invalid token: $(echo $RESPONSE | jq '{success, message}')"

echo ""
echo "4️⃣ Checking Product Model Validation"
echo "===================================="

echo "➤ Testing field constraints..."

# Test minimum values
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Min Test","category":"Test","selling_price":1,"cost_price":1,"stock":0}')
echo "Minimum values: $(echo $RESPONSE | jq '{success, message}')"

# Test string length
LONG_NAME=$(printf 'A%.0s' {1..300})
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d "{\"name\":\"$LONG_NAME\",\"category\":\"Test\",\"selling_price\":10000,\"cost_price\":5000,\"stock\":10}")
echo "Long name: $(echo $RESPONSE | jq '{success, message}')"

echo ""
echo "5️⃣ Monitoring Recent Backend Logs"
echo "================================="

echo "Recent backend logs:"
tail -15 /tmp/pos-backend.log | grep -E "(POST|400|error|Error)"

echo ""
echo "🔧 TROUBLESHOOTING SUGGESTIONS"
echo "=============================="
echo "1. Check frontend form validation"
echo "2. Verify all required fields are sent"
echo "3. Check data types (string vs number)"
echo "4. Ensure positive values for prices and stock"
echo "5. Check for JavaScript errors in browser console"
echo ""
echo "📋 Common 400 Error Causes:"
echo "- Empty or missing 'name' field"
echo "- Negative values for cost_price or selling_price"
echo "- Invalid JSON format"
echo "- Missing Content-Type header"
echo "- Wrong data types in request body"
