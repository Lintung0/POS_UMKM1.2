#!/bin/bash

echo "📋 POS UMKM System Status Report"
echo "================================="
echo "Generated: $(date)"
echo

# Check services
echo "🔧 Service Status:"
echo "=================="

# Backend
if ps aux | grep -v grep | grep -q pos_backend; then
    echo "✅ Backend: Running on port 8082"
else
    echo "❌ Backend: Not running"
fi

# Frontend
if ps aux | grep -v grep | grep -q vite; then
    echo "✅ Frontend: Running on port 3000"
else
    echo "❌ Frontend: Not running"
fi

# MySQL
if ps aux | grep -v grep | grep -q mysqld; then
    echo "✅ MySQL: Running"
else
    echo "❌ MySQL: Not running"
fi

echo

# Test API endpoints
echo "🌐 API Endpoint Tests:"
echo "====================="

# Health check
HEALTH=$(curl -s http://localhost:8082/health)
if echo $HEALTH | grep -q "healthy"; then
    echo "✅ Backend Health: OK"
else
    echo "❌ Backend Health: Failed"
fi

# Login test
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')
if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
    echo "✅ Authentication: Working"
else
    echo "❌ Authentication: Failed"
fi

# Products GET (public)
PRODUCTS_GET=$(curl -s http://localhost:8082/api/products)
if echo $PRODUCTS_GET | grep -q "success"; then
    PRODUCT_COUNT=$(echo $PRODUCTS_GET | jq '.data.products | length')
    echo "✅ Products GET: Working ($PRODUCT_COUNT products)"
else
    echo "❌ Products GET: Failed"
fi

# Products POST (admin only)
if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
    PRODUCTS_POST=$(curl -s -w "HTTP_CODE:%{http_code}" -X POST http://localhost:8082/api/products \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Status Test Product",
        "category": "Test",
        "cost_price": 1000,
        "selling_price": 2000,
        "stock": 5,
        "image": ""
      }')
    
    POST_CODE=$(echo $PRODUCTS_POST | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
    if [ "$POST_CODE" = "201" ]; then
        echo "✅ Products POST: Working (Admin auth OK)"
    else
        echo "❌ Products POST: Failed (HTTP $POST_CODE)"
    fi
else
    echo "⚠️  Products POST: Skipped (no token)"
fi

echo

# Database status
echo "🗄️  Database Status:"
echo "==================="

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
    # Materials count
    MATERIALS=$(curl -s http://localhost:8082/api/materials -H "Authorization: Bearer $TOKEN")
    MATERIAL_COUNT=$(echo $MATERIALS | jq '.data.materials | length')
    echo "📦 Materials: $MATERIAL_COUNT items"
    
    # Products count
    PRODUCT_COUNT=$(echo $PRODUCTS_GET | jq '.data.products | length')
    echo "🛍️  Products: $PRODUCT_COUNT items"
    
    # Dashboard summary
    DASHBOARD=$(curl -s http://localhost:8082/api/dashboard/summary -H "Authorization: Bearer $TOKEN")
    if echo $DASHBOARD | grep -q "success"; then
        echo "📊 Dashboard: Working"
    else
        echo "❌ Dashboard: Failed"
    fi
else
    echo "⚠️  Database tests skipped (no authentication)"
fi

echo

# Frontend status
echo "🖥️  Frontend Status:"
echo "==================="

FRONTEND_RESPONSE=$(curl -s http://localhost:3000)
if echo $FRONTEND_RESPONSE | grep -q "DOCTYPE html"; then
    echo "✅ Frontend accessible at http://localhost:3000"
else
    echo "❌ Frontend not accessible"
fi

echo

# Configuration check
echo "⚙️  Configuration:"
echo "=================="

if [ -f "/home/kirek/code/POS_UMKM-master/backend/.env" ]; then
    echo "✅ Backend .env file exists"
    echo "   JWT_SECRET: $(grep JWT_SECRET /home/kirek/code/POS_UMKM-master/backend/.env | cut -d= -f2 | head -c 20)..."
    echo "   DB_NAME: $(grep DB_NAME /home/kirek/code/POS_UMKM-master/backend/.env | cut -d= -f2)"
else
    echo "❌ Backend .env file missing"
fi

if [ -f "/home/kirek/code/POS_UMKM-master/frontend/vite.config.js" ]; then
    echo "✅ Frontend vite.config.js exists"
    echo "   Proxy target: $(grep -A 3 "proxy:" /home/kirek/code/POS_UMKM-master/frontend/vite.config.js | grep target | awk -F"'" '{print $2}')"
else
    echo "❌ Frontend vite.config.js missing"
fi

echo

# Issue diagnosis
echo "🔍 Issue Diagnosis:"
echo "=================="

if [ "$POST_CODE" = "201" ]; then
    echo "✅ Backend API working correctly"
    echo "✅ Authentication working correctly"
    echo "✅ Product creation working via API"
    echo
    echo "🎯 The issue is likely in the frontend:"
    echo "   1. Check browser console for JavaScript errors"
    echo "   2. Check browser Network tab for failed requests"
    echo "   3. Verify localStorage token persistence"
    echo "   4. Check React component state management"
    echo
    echo "🛠️  Debugging steps added:"
    echo "   - Enhanced error logging in ProductsPage.jsx"
    echo "   - Enhanced logging in axios interceptors"
    echo "   - Enhanced logging in AuthContext"
    echo
    echo "📝 To reproduce the issue:"
    echo "   1. Open http://localhost:3000 in browser"
    echo "   2. Login with admin/admin123"
    echo "   3. Go to Products page"
    echo "   4. Try to add a new product"
    echo "   5. Check browser console for detailed logs"
else
    echo "❌ Backend API has issues"
    echo "   HTTP Code: $POST_CODE"
    echo "   This needs to be fixed first"
fi

echo
echo "🏁 Report Complete"
echo "=================="
