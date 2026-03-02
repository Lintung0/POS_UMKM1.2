#!/bin/bash

echo "🔍 DEBUGGING 403 ERRORS"
echo "======================="

BASE_URL="http://localhost:8082/api"

echo "1️⃣ Testing Authentication..."
LOGIN_RESPONSE=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}')
SUCCESS=$(echo $LOGIN_RESPONSE | jq '.success')
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')

if [ "$SUCCESS" = "true" ]; then
    echo "✅ Login successful"
    echo "   Token: ${TOKEN:0:30}..."
else
    echo "❌ Login failed: $(echo $LOGIN_RESPONSE | jq '.message')"
    exit 1
fi

echo ""
echo "2️⃣ Testing Materials POST with different scenarios..."

echo "➤ Test 1: Valid request with token"
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"name":"Debug Material 1","unit":"gram","stock":100,"min_stock":10,"cost_per_unit":50}')
echo "   Status: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo "➤ Test 2: Request without token"
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Content-Type: application/json" -d '{"name":"Debug Material 2","unit":"gram","stock":100,"min_stock":10,"cost_per_unit":50}')
echo "   Status: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo "➤ Test 3: Request with invalid token"
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer invalid_token" -H "Content-Type: application/json" -d '{"name":"Debug Material 3","unit":"gram","stock":100,"min_stock":10,"cost_per_unit":50}')
echo "   Status: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo "➤ Test 4: Request with kasir token"
KASIR_LOGIN=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"kasir","password":"kasir123"}')
KASIR_TOKEN=$(echo $KASIR_LOGIN | jq -r '.data.token')
RESPONSE=$(curl -s "$BASE_URL/materials" -X POST -H "Authorization: Bearer $KASIR_TOKEN" -H "Content-Type: application/json" -d '{"name":"Debug Material 4","unit":"gram","stock":100,"min_stock":10,"cost_per_unit":50}')
echo "   Status: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo ""
echo "3️⃣ Testing Frontend API calls..."
echo "➤ Checking if frontend is making requests correctly..."

# Check if frontend is running
FRONTEND_STATUS=$(curl -s "http://localhost:3006" -o /dev/null -w "%{http_code}")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ Frontend is running on http://localhost:3006"
else
    echo "❌ Frontend not accessible"
fi

echo ""
echo "4️⃣ Checking CORS configuration..."
CORS_TEST=$(curl -s -H "Origin: http://localhost:3006" -H "Access-Control-Request-Method: POST" -H "Access-Control-Request-Headers: authorization,content-type" -X OPTIONS "$BASE_URL/materials" -w "%{http_code}")
echo "   CORS preflight response: $CORS_TEST"

echo ""
echo "5️⃣ Monitoring backend logs for errors..."
echo "   Recent backend logs:"
tail -10 /tmp/pos-backend.log

echo ""
echo "🔧 TROUBLESHOOTING SUGGESTIONS:"
echo "================================"
echo "1. Check browser console for JavaScript errors"
echo "2. Verify localStorage has valid token"
echo "3. Check network tab for request headers"
echo "4. Ensure frontend is sending Authorization header"
echo "5. Check if token is expired or malformed"
echo ""
echo "📋 Quick Frontend Debug Commands:"
echo "================================"
echo "// In browser console:"
echo "console.log('Token:', localStorage.getItem('token'));"
echo "console.log('User:', localStorage.getItem('user'));"
echo ""
echo "// Clear and re-login:"
echo "localStorage.clear();"
echo "// Then login again"
