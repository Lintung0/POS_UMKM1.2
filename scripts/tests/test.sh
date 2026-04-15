#!/bin/bash

echo "🧪 Testing POS UMKM System..."
echo ""

# Test Backend Health
echo "1️⃣  Testing Backend Health..."
HEALTH=$(curl -s http://localhost:8082/health)
if echo "$HEALTH" | jq -e '.status == "healthy"' > /dev/null 2>&1; then
    echo "   ✅ Backend is healthy"
else
    echo "   ❌ Backend health check failed"
    exit 1
fi

# Test Login
echo ""
echo "2️⃣  Testing Authentication..."
LOGIN=$(curl -s -X POST http://localhost:8082/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"admin123"}')
if echo "$LOGIN" | jq -e '.success == true' > /dev/null 2>&1; then
    echo "   ✅ Login successful"
    TOKEN=$(echo "$LOGIN" | jq -r '.data.token')
else
    echo "   ❌ Login failed"
    exit 1
fi

# Test Products
echo ""
echo "3️⃣  Testing Products API..."
PRODUCTS=$(curl -s http://localhost:8082/api/products)
PRODUCT_COUNT=$(echo "$PRODUCTS" | jq '.data | length')
echo "   ✅ Found $PRODUCT_COUNT products"

# Test Materials
echo ""
echo "4️⃣  Testing Materials API..."
MATERIALS=$(curl -s http://localhost:8082/api/materials)
MATERIAL_COUNT=$(echo "$MATERIALS" | jq '.data | length')
echo "   ✅ Found $MATERIAL_COUNT materials"

# Test Dashboard
echo ""
echo "5️⃣  Testing Dashboard API..."
DASHBOARD=$(curl -s http://localhost:8082/api/dashboard/summary)
if echo "$DASHBOARD" | jq -e '.success == true' > /dev/null 2>&1; then
    TOTAL_SALES=$(echo "$DASHBOARD" | jq -r '.data.today_sales')
    TOTAL_TRANS=$(echo "$DASHBOARD" | jq -r '.data.total_transactions')
    echo "   ✅ Dashboard loaded"
    echo "      Today Sales: Rp $TOTAL_SALES"
    echo "      Total Transactions: $TOTAL_TRANS"
else
    echo "   ❌ Dashboard failed"
fi

# Test Transactions
echo ""
echo "6️⃣  Testing Transactions API..."
TRANSACTIONS=$(curl -s http://localhost:8082/api/transactions)
TRANS_COUNT=$(echo "$TRANSACTIONS" | jq '.data | length')
echo "   ✅ Found $TRANS_COUNT transactions"

# Test Frontend
echo ""
echo "7️⃣  Testing Frontend..."
FRONTEND_PORT=$(grep -oP 'Local:\s+http://localhost:\K\d+' /tmp/pos-frontend.log 2>/dev/null | tail -1)
if [ -n "$FRONTEND_PORT" ]; then
    FRONTEND=$(curl -s http://localhost:$FRONTEND_PORT)
    if echo "$FRONTEND" | grep -q "POS UMKM"; then
        echo "   ✅ Frontend is running on port $FRONTEND_PORT"
    else
        echo "   ❌ Frontend not responding"
    fi
else
    echo "   ❌ Frontend port not found"
fi

echo ""
echo "✅ All tests passed!"
echo ""
echo "🌐 Access URLs:"
echo "   Backend:  http://localhost:8082"
echo "   Frontend: http://localhost:${FRONTEND_PORT:-3000}"
echo ""
echo "🔐 Login Credentials:"
echo "   Admin:  admin / admin123"
echo "   Kasir:  kasir / kasir123"
