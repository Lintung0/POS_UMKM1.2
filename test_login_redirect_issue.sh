#!/bin/bash

echo "🔍 Testing Product Creation Issue - Redirect to Login"
echo "=================================================="
echo

# Step 1: Login and get token
echo "1️⃣ Logging in as admin..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')
echo "✅ Login successful, token obtained"

# Step 2: Simulate the exact product creation request from frontend
echo
echo "2️⃣ Simulating frontend product creation request..."
TIMESTAMP=$(date +%s)

# This simulates exactly what the frontend sends
PRODUCT_DATA='{
  "name": "Test Product Frontend",
  "category": "Test Category",
  "cost_price": 5000,
  "selling_price": 8000,
  "stock": 10,
  "image": ""
}'

echo "📤 Sending product creation request..."
CREATE_RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X POST http://localhost:8082/api/products \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PRODUCT_DATA")

HTTP_CODE=$(echo $CREATE_RESPONSE | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
RESPONSE_BODY=$(echo $CREATE_RESPONSE | sed 's/HTTP_CODE:[0-9]*$//')

echo "📥 Response received:"
echo "   HTTP Code: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "✅ Product creation successful"
    echo "$RESPONSE_BODY" | jq .
    PRODUCT_ID=$(echo $RESPONSE_BODY | jq -r '.data.id')
    echo "   New Product ID: $PRODUCT_ID"
elif [ "$HTTP_CODE" = "401" ]; then
    echo "❌ 401 Unauthorized - This would cause redirect to login!"
    echo "   This is the issue you're experiencing"
    echo "$RESPONSE_BODY" | jq .
elif [ "$HTTP_CODE" = "403" ]; then
    echo "❌ 403 Forbidden - Permission denied"
    echo "$RESPONSE_BODY" | jq .
else
    echo "❌ Unexpected response code: $HTTP_CODE"
    echo "$RESPONSE_BODY" | jq .
fi

# Step 3: Test token validity after the request
echo
echo "3️⃣ Testing token validity after product creation..."
VALIDATE_RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X GET http://localhost:8082/api/products \
  -H "Authorization: Bearer $TOKEN")

VALIDATE_HTTP_CODE=$(echo $VALIDATE_RESPONSE | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
VALIDATE_BODY=$(echo $VALIDATE_RESPONSE | sed 's/HTTP_CODE:[0-9]*$//')

if [ "$VALIDATE_HTTP_CODE" = "200" ]; then
    echo "✅ Token still valid after product creation"
    PRODUCT_COUNT=$(echo $VALIDATE_BODY | jq '.data.products | length')
    echo "   Found $PRODUCT_COUNT products"
elif [ "$VALIDATE_HTTP_CODE" = "401" ]; then
    echo "❌ Token became invalid after product creation!"
    echo "   This explains the redirect to login"
else
    echo "⚠️  Unexpected validation response: $VALIDATE_HTTP_CODE"
fi

# Step 4: Test with a fresh token to see if it's a token expiry issue
echo
echo "4️⃣ Testing with fresh token..."
FRESH_LOGIN=$(curl -s -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

FRESH_TOKEN=$(echo $FRESH_LOGIN | jq -r '.data.token')

FRESH_TEST=$(curl -s -w "HTTP_CODE:%{http_code}" -X POST http://localhost:8082/api/products \
  -H "Authorization: Bearer $FRESH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Fresh Token Test",
    "category": "Test",
    "cost_price": 3000,
    "selling_price": 5000,
    "stock": 5,
    "image": ""
  }')

FRESH_HTTP_CODE=$(echo $FRESH_TEST | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)

if [ "$FRESH_HTTP_CODE" = "200" ] || [ "$FRESH_HTTP_CODE" = "201" ]; then
    echo "✅ Fresh token works fine"
else
    echo "❌ Fresh token also fails: $FRESH_HTTP_CODE"
fi

# Step 5: Check JWT token details
echo
echo "5️⃣ Analyzing JWT token..."
echo "Original token: ${TOKEN:0:50}..."
echo "Fresh token:    ${FRESH_TOKEN:0:50}..."

if [ "$TOKEN" = "$FRESH_TOKEN" ]; then
    echo "⚠️  Tokens are identical - possible caching issue"
else
    echo "✅ Tokens are different - normal behavior"
fi

echo
echo "🔍 Diagnosis:"
if [ "$HTTP_CODE" = "401" ]; then
    echo "❌ ISSUE CONFIRMED: Product creation returns 401 Unauthorized"
    echo "   This causes the frontend to redirect to login page"
    echo "   Possible causes:"
    echo "   - Token expiry during request"
    echo "   - JWT validation failure"
    echo "   - Middleware authentication issue"
elif [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "✅ No authentication issue detected"
    echo "   The problem might be:"
    echo "   - Frontend-specific issue"
    echo "   - Browser session management"
    echo "   - React state management"
else
    echo "⚠️  Unexpected behavior detected"
fi
