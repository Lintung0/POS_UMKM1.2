#!/bin/bash

echo "🧪 Testing Product Creation Flow..."
echo

# Step 1: Login
echo "1️⃣ Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
    echo "✅ Login successful"
    echo "   Token: ${TOKEN:0:20}..."
else
    echo "❌ Login failed"
    echo $LOGIN_RESPONSE | jq .
    exit 1
fi

# Step 2: Test Get Products
echo
echo "2️⃣ Testing Get Products..."
PRODUCTS_RESPONSE=$(curl -s -X GET http://localhost:8082/api/products \
  -H "Authorization: Bearer $TOKEN")

PRODUCT_COUNT=$(echo $PRODUCTS_RESPONSE | jq '.data.products | length')
echo "✅ Found $PRODUCT_COUNT products"

# Step 3: Test Create Product
echo
echo "3️⃣ Testing Create Product..."
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

SUCCESS=$(echo $CREATE_RESPONSE | jq -r '.success')
if [ "$SUCCESS" = "true" ]; then
    PRODUCT_ID=$(echo $CREATE_RESPONSE | jq -r '.data.id')
    PRODUCT_NAME=$(echo $CREATE_RESPONSE | jq -r '.data.name')
    echo "✅ Product created successfully"
    echo "   Product ID: $PRODUCT_ID"
    echo "   Product Name: $PRODUCT_NAME"
else
    echo "❌ Product creation failed"
    echo $CREATE_RESPONSE | jq .
    exit 1
fi

# Step 4: Test Token Validation
echo
echo "4️⃣ Testing Token Validation..."
VALIDATE_RESPONSE=$(curl -s -X GET http://localhost:8082/api/products \
  -H "Authorization: Bearer $TOKEN")

VALIDATE_SUCCESS=$(echo $VALIDATE_RESPONSE | jq -r '.success')
if [ "$VALIDATE_SUCCESS" = "true" ]; then
    echo "✅ Token still valid after product creation"
else
    echo "❌ Token validation failed"
    echo $VALIDATE_RESPONSE | jq .
fi

# Step 5: Test Recipe Creation (the 403 error from logs)
echo
echo "5️⃣ Testing Recipe Creation..."
RECIPE_RESPONSE=$(curl -s -X POST http://localhost:8082/api/recipes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"product_id\": $PRODUCT_ID,
    \"recipes\": [
      {
        \"material_id\": 1,
        \"quantity\": 2
      }
    ]
  }")

RECIPE_SUCCESS=$(echo $RECIPE_RESPONSE | jq -r '.success')
if [ "$RECIPE_SUCCESS" = "true" ]; then
    echo "✅ Recipe created successfully"
else
    echo "❌ Recipe creation failed"
    echo "   Response: $(echo $RECIPE_RESPONSE | jq .)"
    
    # Check if it's a 403 error
    ERROR_MSG=$(echo $RECIPE_RESPONSE | jq -r '.message')
    if [[ "$ERROR_MSG" == *"Akses ditolak"* ]]; then
        echo "   🔍 This is a 403 Forbidden error - authorization problem"
    fi
fi

echo
echo "🎉 All tests completed!"
