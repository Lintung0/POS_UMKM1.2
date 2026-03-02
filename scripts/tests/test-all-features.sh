#!/bin/bash

echo "🧪 Testing All POS UMKM Features..."
echo "=================================="

BASE_URL="http://localhost:8082/api"

# Test 1: Health Check
echo "1. 🏥 Health Check"
curl -s "$BASE_URL/../health" | jq '.' 2>/dev/null || echo "❌ Health check failed"
echo ""

# Test 2: Authentication
echo "2. 🔐 Authentication Test"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')
echo "Login Response: $LOGIN_RESPONSE"
echo ""

# Test 3: Products
echo "3. 📦 Products Test"
curl -s "$BASE_URL/products" | jq '.data | length' 2>/dev/null && echo "✅ Products endpoint working" || echo "❌ Products endpoint failed"
echo ""

# Test 4: Materials
echo "4. 🧱 Materials Test"
curl -s "$BASE_URL/materials" | jq '.data | length' 2>/dev/null && echo "✅ Materials endpoint working" || echo "❌ Materials endpoint failed"
echo ""

# Test 5: Dashboard
echo "5. 📊 Dashboard Test"
curl -s "$BASE_URL/dashboard/summary" | jq '.' 2>/dev/null && echo "✅ Dashboard endpoint working" || echo "❌ Dashboard endpoint failed"
echo ""

# Test 6: Transactions
echo "6. 💰 Transactions Test"
curl -s "$BASE_URL/transactions" | jq '.data | length' 2>/dev/null && echo "✅ Transactions endpoint working" || echo "❌ Transactions endpoint failed"
echo ""

echo "🌐 Frontend URL: http://localhost:3000"
echo "🔧 Backend URL: http://localhost:8082"
echo ""
echo "📋 Manual Test Checklist:"
echo "□ Login page loads"
echo "□ Dashboard shows data"
echo "□ Products page loads and shows products"
echo "□ Materials page loads and shows materials"
echo "□ Kasir/POS page works"
echo "□ Transactions page shows history"
echo "□ Reports page generates reports"
echo "□ Settings page loads (including theme switching)"
echo ""
echo "🚀 Open browser: http://localhost:3000"
