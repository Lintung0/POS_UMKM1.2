#!/bin/bash

echo "🧹 CLEANING TEST DATA & RESEEDING PROPER DATA"
echo "============================================="

BASE_URL="http://localhost:8082/api"

# Get admin token
ADMIN_TOKEN=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}' | jq -r '.data.token')

echo "🔐 Admin token obtained"
echo ""

echo "1️⃣ Current Database State"
echo "========================="

echo "➤ Current materials count:"
MATERIALS=$(curl -s "$BASE_URL/materials")
MATERIAL_COUNT=$(echo $MATERIALS | jq '.data.materials | length')
echo "   Total materials: $MATERIAL_COUNT"

echo "➤ Current products count:"
PRODUCTS=$(curl -s "$BASE_URL/products")
PRODUCT_COUNT=$(echo $PRODUCTS | jq '.data.products | length')
echo "   Total products: $PRODUCT_COUNT"

echo ""
echo "2️⃣ Cleaning Test Data"
echo "===================="

echo "➤ Removing test materials..."
# Get all test materials (containing "Test", "Debug", "CORS", etc.)
TEST_MATERIALS=$(echo $MATERIALS | jq -r '.data.materials[] | select(.name | test("Test|Debug|CORS|Recipe|Token|Dependency")) | .id')

for ID in $TEST_MATERIALS; do
    if [ "$ID" != "null" ] && [ "$ID" != "" ]; then
        DELETE_RESULT=$(curl -s "$BASE_URL/materials/$ID" -X DELETE -H "Authorization: Bearer $ADMIN_TOKEN")
        SUCCESS=$(echo $DELETE_RESULT | jq '.success')
        if [ "$SUCCESS" = "true" ]; then
            echo "   ✅ Deleted material ID: $ID"
        else
            echo "   ❌ Failed to delete material ID: $ID - $(echo $DELETE_RESULT | jq -r '.message')"
        fi
    fi
done

echo "➤ Removing test products..."
# Get all test products
TEST_PRODUCTS=$(echo $PRODUCTS | jq -r '.data.products[] | select(.name | test("Test|Debug|CORS|Recipe|Token|Zero|Valid|Updated")) | .id')

for ID in $TEST_PRODUCTS; do
    if [ "$ID" != "null" ] && [ "$ID" != "" ]; then
        DELETE_RESULT=$(curl -s "$BASE_URL/products/$ID" -X DELETE -H "Authorization: Bearer $ADMIN_TOKEN")
        SUCCESS=$(echo $DELETE_RESULT | jq '.success')
        if [ "$SUCCESS" = "true" ]; then
            echo "   ✅ Deleted product ID: $ID"
        else
            echo "   ❌ Failed to delete product ID: $ID - $(echo $DELETE_RESULT | jq -r '.message')"
        fi
    fi
done

echo ""
echo "3️⃣ Restarting System to Trigger Seeder"
echo "======================================="

cd /home/kirek/code/pos-umkm
./stop.sh
sleep 3
./start.sh

echo ""
echo "4️⃣ Waiting for System to Start..."
echo "================================="
sleep 5

# Check if system is ready
HEALTH_CHECK=$(curl -s "http://localhost:8082/health" | jq '.status')
if [ "$HEALTH_CHECK" = "\"healthy\"" ]; then
    echo "✅ System is healthy and ready"
else
    echo "❌ System not ready, waiting more..."
    sleep 5
fi

echo ""
echo "5️⃣ Verifying New Data"
echo "===================="

# Get new admin token
NEW_ADMIN_TOKEN=$(curl -s "http://localhost:8082/api/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}' | jq -r '.data.token')

echo "➤ New materials after seeding:"
NEW_MATERIALS=$(curl -s "http://localhost:8082/api/materials")
echo $NEW_MATERIALS | jq '.data.materials[] | {id, name, stock, unit, price_per_unit}'

echo ""
echo "➤ New products after seeding:"
NEW_PRODUCTS=$(curl -s "http://localhost:8082/api/products")
echo $NEW_PRODUCTS | jq '.data.products[] | {id, name, category, selling_price, stock}'

echo ""
echo "6️⃣ Summary"
echo "=========="

NEW_MATERIAL_COUNT=$(echo $NEW_MATERIALS | jq '.data.materials | length')
NEW_PRODUCT_COUNT=$(echo $NEW_PRODUCTS | jq '.data.products | length')

echo "Materials: $MATERIAL_COUNT → $NEW_MATERIAL_COUNT"
echo "Products: $PRODUCT_COUNT → $NEW_PRODUCT_COUNT"

echo ""
echo "✅ Database cleanup and reseeding completed!"
echo "🌐 Frontend: Check the updated data in the UI"
echo "📊 The data should now show proper business-ready items"
