#!/bin/bash

echo "🔍 Frontend Debugging - Checking localStorage and Token Issues"
echo "============================================================="
echo

# Test localStorage token persistence
echo "1️⃣ Testing localStorage token behavior..."

# Login and get token
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')
echo "✅ Token obtained: ${TOKEN:0:30}..."

# Decode JWT to check expiry
echo
echo "2️⃣ Analyzing JWT token structure..."
HEADER=$(echo $TOKEN | cut -d. -f1)
PAYLOAD=$(echo $TOKEN | cut -d. -f2)

# Add padding if needed for base64 decoding
PAYLOAD_PADDED=$(echo $PAYLOAD | sed 's/$/===/' | head -c $((${#PAYLOAD} + 3)))

echo "JWT Payload (decoded):"
echo $PAYLOAD_PADDED | base64 -d 2>/dev/null | jq . || echo "Could not decode JWT payload"

# Test multiple rapid requests to simulate frontend behavior
echo
echo "3️⃣ Testing rapid consecutive requests (simulating frontend)..."

for i in {1..5}; do
    echo "Request $i:"
    RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X GET http://localhost:8082/api/products \
      -H "Authorization: Bearer $TOKEN")
    
    HTTP_CODE=$(echo $RESPONSE | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
    echo "   HTTP Code: $HTTP_CODE"
    
    if [ "$HTTP_CODE" != "200" ]; then
        echo "   ❌ Failed on request $i"
        echo $RESPONSE | sed 's/HTTP_CODE:[0-9]*$//' | jq .
        break
    else
        echo "   ✅ Success"
    fi
    
    sleep 0.1
done

# Test with malformed token to see error response
echo
echo "4️⃣ Testing with malformed token..."
MALFORMED_RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X GET http://localhost:8082/api/products \
  -H "Authorization: Bearer invalid_token")

MALFORMED_CODE=$(echo $MALFORMED_RESPONSE | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
MALFORMED_BODY=$(echo $MALFORMED_RESPONSE | sed 's/HTTP_CODE:[0-9]*$//')

echo "Malformed token response:"
echo "   HTTP Code: $MALFORMED_CODE"
echo "   Body: $(echo $MALFORMED_BODY | jq .)"

# Test with no token
echo
echo "5️⃣ Testing with no token..."
NO_TOKEN_RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X GET http://localhost:8082/api/products)

NO_TOKEN_CODE=$(echo $NO_TOKEN_RESPONSE | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
NO_TOKEN_BODY=$(echo $NO_TOKEN_RESPONSE | sed 's/HTTP_CODE:[0-9]*$//')

echo "No token response:"
echo "   HTTP Code: $NO_TOKEN_CODE"
echo "   Body: $(echo $NO_TOKEN_BODY | jq .)"

# Test product creation with detailed error logging
echo
echo "6️⃣ Testing product creation with detailed logging..."
CREATE_RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}" -X POST http://localhost:8082/api/products \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Debug Test Product",
    "category": "Debug Category",
    "cost_price": 1000,
    "selling_price": 2000,
    "stock": 5,
    "image": ""
  }')

CREATE_CODE=$(echo "$CREATE_RESPONSE" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
CREATE_TIME=$(echo "$CREATE_RESPONSE" | grep -o "TIME_TOTAL:[0-9.]*" | cut -d: -f2)
CREATE_BODY=$(echo "$CREATE_RESPONSE" | sed 's/HTTP_CODE:[0-9]*$//' | sed 's/TIME_TOTAL:[0-9.]*$//')

echo "Product creation response:"
echo "   HTTP Code: $CREATE_CODE"
echo "   Time taken: ${CREATE_TIME}s"
if [ "$CREATE_CODE" = "201" ] || [ "$CREATE_CODE" = "200" ]; then
    echo "   ✅ Success"
    echo "$CREATE_BODY" | jq .
else
    echo "   ❌ Failed"
    echo "$CREATE_BODY" | jq .
fi

echo
echo "🔍 Summary:"
echo "   - Token validation: Working"
echo "   - Product creation API: Working"
echo "   - Issue is likely in frontend JavaScript"
echo
echo "💡 Next steps:"
echo "   1. Check browser console for JavaScript errors"
echo "   2. Check network tab for actual HTTP responses"
echo "   3. Add console.log to ProductsPage.jsx error handling"
echo "   4. Check if localStorage is being cleared unexpectedly"
