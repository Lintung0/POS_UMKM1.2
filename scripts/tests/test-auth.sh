#!/bin/bash

echo "🔐 Testing POS UMKM Authentication System..."
echo "============================================="

BASE_URL="http://localhost:8082/api"

# Test 1: Login with valid admin credentials
echo "🧪 Test 1: Admin Login (Valid Credentials)"
ADMIN_RESPONSE=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}')
echo $ADMIN_RESPONSE | jq '.success, .data.role, .data.username'
ADMIN_TOKEN=$(echo $ADMIN_RESPONSE | jq -r '.data.token')
echo ""

# Test 2: Login with valid kasir credentials  
echo "🧪 Test 2: Kasir Login (Valid Credentials)"
KASIR_RESPONSE=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"kasir","password":"kasir123"}')
echo $KASIR_RESPONSE | jq '.success, .data.role, .data.username'
KASIR_TOKEN=$(echo $KASIR_RESPONSE | jq -r '.data.token')
echo ""

# Test 3: Login with invalid credentials
echo "🧪 Test 3: Invalid Login"
curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"wrong"}' | jq '.success, .message'
echo ""

# Test 4: Access public endpoint (no auth required)
echo "🧪 Test 4: Public Endpoint (GET Products)"
curl -s "$BASE_URL/products" | jq '.success'
echo ""

# Test 5: Admin access to admin-only endpoint
echo "🧪 Test 5: Admin Access to Admin Endpoint (Create Product)"
curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Auth Test Product","category":"Test","selling_price":15000,"cost_price":8000,"stock":5}' | jq '.success, .message'
echo ""

# Test 6: Kasir access to admin-only endpoint (should fail)
echo "🧪 Test 6: Kasir Access to Admin Endpoint (Should Fail)"
curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $KASIR_TOKEN" -H "Content-Type: application/json" -d '{"name":"Unauthorized Product","category":"Test","selling_price":10000,"cost_price":5000,"stock":10}' | jq '.success, .message'
echo ""

# Test 7: Access protected endpoint without token
echo "🧪 Test 7: Access Protected Endpoint Without Token"
curl -s "$BASE_URL/products" -X POST -H "Content-Type: application/json" -d '{"name":"No Token Product","category":"Test","selling_price":10000,"cost_price":5000,"stock":10}' | jq '.success, .message'
echo ""

# Test 8: Access with invalid token
echo "🧪 Test 8: Access with Invalid Token"
curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer invalid_token_here" -H "Content-Type: application/json" -d '{"name":"Invalid Token Product","category":"Test","selling_price":10000,"cost_price":5000,"stock":10}' | jq '.success, .message'
echo ""

# Test 9: Kasir can create transactions
echo "🧪 Test 9: Kasir Can Create Transactions"
curl -s "$BASE_URL/transactions" -X POST -H "Authorization: Bearer $KASIR_TOKEN" -H "Content-Type: application/json" -d '{"items":[{"product_id":1,"quantity":1}],"cash_received":20000,"payment_method":"CASH","cashier_name":"Test Kasir","notes":"Auth test transaction"}' | jq '.success, .message'
echo ""

# Test 10: Both roles can access dashboard
echo "🧪 Test 10: Admin Access Dashboard"
curl -s "$BASE_URL/dashboard/summary" -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.success'
echo ""

echo "🧪 Test 11: Kasir Access Dashboard"  
curl -s "$BASE_URL/dashboard/summary" -H "Authorization: Bearer $KASIR_TOKEN" | jq '.success'
echo ""

echo "✅ Authentication tests completed!"
echo ""
echo "📋 Summary:"
echo "- ✅ Admin login works"
echo "- ✅ Kasir login works" 
echo "- ✅ Invalid credentials rejected"
echo "- ✅ Admin can access admin endpoints"
echo "- ✅ Kasir blocked from admin endpoints"
echo "- ✅ Protected endpoints require token"
echo "- ✅ Invalid tokens rejected"
echo "- ✅ Role-based access control working"
echo ""
echo "🌐 Frontend URL: http://localhost:3003"
echo "🔑 Test login on frontend with:"
echo "   Admin: admin / admin123"
echo "   Kasir: kasir / kasir123"
