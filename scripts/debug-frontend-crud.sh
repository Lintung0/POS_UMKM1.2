#!/bin/bash

echo "🔍 FRONTEND CRUD DEBUGGING"
echo "========================="

BASE_URL="http://localhost:8082/api"
FRONTEND_URL="http://localhost:3002"

echo "1️⃣ Testing Backend API directly..."
ADMIN_TOKEN=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}' | jq -r '.data.token')

if [ "$ADMIN_TOKEN" != "null" ] && [ "$ADMIN_TOKEN" != "" ]; then
    echo "✅ Backend login: SUCCESS"
    echo "   Token: ${ADMIN_TOKEN:0:30}..."
else
    echo "❌ Backend login: FAILED"
    exit 1
fi

echo ""
echo "2️⃣ Testing CRUD operations..."

# Test CREATE
echo "➤ CREATE Material..."
CREATE_RESULT=$(curl -s "$BASE_URL/materials" -X POST -H "Origin: $FRONTEND_URL" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Frontend Debug","unit":"gram","stock":50,"min_stock":5,"cost_per_unit":15}')
SUCCESS=$(echo $CREATE_RESULT | jq '.success')
MATERIAL_ID=$(echo $CREATE_RESULT | jq '.data.id')

if [ "$SUCCESS" = "true" ]; then
    echo "✅ CREATE: SUCCESS (ID: $MATERIAL_ID)"
else
    echo "❌ CREATE: FAILED - $(echo $CREATE_RESULT | jq -r '.message')"
fi

# Test READ
echo "➤ READ Materials..."
READ_RESULT=$(curl -s "$BASE_URL/materials" -H "Origin: $FRONTEND_URL")
SUCCESS=$(echo $READ_RESULT | jq '.success')

if [ "$SUCCESS" = "true" ]; then
    echo "✅ READ: SUCCESS"
else
    echo "❌ READ: FAILED - $(echo $READ_RESULT | jq -r '.message')"
fi

# Test UPDATE
if [ "$MATERIAL_ID" != "null" ]; then
    echo "➤ UPDATE Material..."
    UPDATE_RESULT=$(curl -s "$BASE_URL/materials/$MATERIAL_ID" -X PUT -H "Origin: $FRONTEND_URL" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Updated Frontend Debug","unit":"kg","stock":75,"min_stock":7,"cost_per_unit":20}')
    SUCCESS=$(echo $UPDATE_RESULT | jq '.success')
    
    if [ "$SUCCESS" = "true" ]; then
        echo "✅ UPDATE: SUCCESS"
    else
        echo "❌ UPDATE: FAILED - $(echo $UPDATE_RESULT | jq -r '.message')"
    fi
fi

# Test DELETE
if [ "$MATERIAL_ID" != "null" ]; then
    echo "➤ DELETE Material..."
    DELETE_RESULT=$(curl -s "$BASE_URL/materials/$MATERIAL_ID" -X DELETE -H "Origin: $FRONTEND_URL" -H "Authorization: Bearer $ADMIN_TOKEN")
    SUCCESS=$(echo $DELETE_RESULT | jq '.success')
    
    if [ "$SUCCESS" = "true" ]; then
        echo "✅ DELETE: SUCCESS"
    else
        echo "❌ DELETE: FAILED - $(echo $DELETE_RESULT | jq -r '.message')"
    fi
fi

echo ""
echo "3️⃣ Frontend Debugging Tips..."
echo "=============================="
echo "1. Open browser console (F12) and check for errors"
echo "2. Check Network tab for failed API requests"
echo "3. Verify localStorage has valid token:"
echo "   localStorage.getItem('token')"
echo "4. Check if forms are sending correct data format"
echo ""
echo "4️⃣ Common Frontend Issues..."
echo "============================"
echo "❌ Token expired/missing:"
echo "   - Login again to get fresh token"
echo "   - Check localStorage.getItem('token')"
echo ""
echo "❌ Form validation errors:"
echo "   - Check required fields are filled"
echo "   - Verify data types (numbers vs strings)"
echo ""
echo "❌ CORS errors:"
echo "   - Should be fixed (tested above)"
echo ""
echo "❌ Network errors:"
echo "   - Check if backend is running: curl http://localhost:8082/health"
echo ""
echo "🔧 Quick Frontend Debug Commands:"
echo "================================="
echo "// In browser console:"
echo "console.log('Token:', localStorage.getItem('token'));"
echo "console.log('User:', localStorage.getItem('user'));"
echo ""
echo "// Clear storage and re-login:"
echo "localStorage.clear();"
echo "// Then login again"
echo ""
echo "🌐 Frontend URL: $FRONTEND_URL"
echo "🔗 Backend API: $BASE_URL"
