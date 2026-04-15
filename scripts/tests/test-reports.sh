#!/bin/bash

echo "🧪 Testing POS UMKM Reports System..."
echo "=================================="

BASE_URL="http://localhost:8082/api"

# Test 1: Get all transactions
echo "📋 Test 1: Get All Transactions"
curl -s "$BASE_URL/transactions" | jq '.success, .data.pagination.total'
echo ""

# Test 2: Daily report for today
echo "📅 Test 2: Daily Report (Today)"
TODAY=$(date +%Y-%m-%d)
curl -s "$BASE_URL/transactions/report/daily?date=$TODAY" | jq '.success, .data'
echo ""

# Test 3: Daily report for specific date with data
echo "📅 Test 3: Daily Report (2026-01-14 - has data)"
curl -s "$BASE_URL/transactions/report/daily?date=2026-01-14" | jq '.success, .data'
echo ""

# Test 4: Monthly report for current month
echo "📊 Test 4: Monthly Report (Current Month)"
CURRENT_MONTH=$(date +%Y-%m)
curl -s "$BASE_URL/transactions/report/monthly?month=$CURRENT_MONTH" | jq '.success, .data.report'
echo ""

# Test 5: Monthly report for January 2026 (has data)
echo "📊 Test 5: Monthly Report (2026-01 - has data)"
curl -s "$BASE_URL/transactions/report/monthly?month=2026-01" | jq '.success, .data.report'
echo ""

# Test 6: Get specific transaction
echo "🔍 Test 6: Get Transaction by ID"
curl -s "$BASE_URL/transactions/1" | jq '.success, .data.id, .data.total_amount'
echo ""

echo "✅ All report tests completed!"
echo ""
echo "🌐 Frontend URL: http://localhost:3002"
echo "📊 Go to Reports page to test the UI"
