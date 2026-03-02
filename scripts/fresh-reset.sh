#!/bin/bash

echo "🔄 FRESH DATABASE RESET & SEEDING"
echo "================================="

echo "1️⃣ Stopping system..."
cd /home/kirek/code/pos-umkm
./stop.sh

echo ""
echo "2️⃣ Backing up current database..."
cp backend/pos_umkm.db backend/pos_umkm.db.backup.$(date +%Y%m%d_%H%M%S)

echo ""
echo "3️⃣ Removing current database..."
rm -f backend/pos_umkm.db

echo ""
echo "4️⃣ Starting system (will create fresh DB with seeder)..."
./start.sh

echo ""
echo "5️⃣ Waiting for system to initialize..."
sleep 8

echo ""
echo "6️⃣ Checking seeder results..."

# Check backend logs for seeder output
echo "➤ Backend seeder logs:"
tail -20 /tmp/pos-backend.log | grep -E "(Created|Seeding|✅|❌)"

echo ""
echo "7️⃣ Verifying fresh data..."

# Get admin token
ADMIN_TOKEN=$(curl -s "http://localhost:8082/api/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}' | jq -r '.data.token')

if [ "$ADMIN_TOKEN" != "null" ] && [ "$ADMIN_TOKEN" != "" ]; then
    echo "✅ Authentication working"
    
    echo ""
    echo "➤ Fresh materials:"
    curl -s "http://localhost:8082/api/materials" | jq '.data.materials[] | {id, name, stock, unit, price_per_unit, supplier}'
    
    echo ""
    echo "➤ Fresh products:"
    curl -s "http://localhost:8082/api/products" | jq '.data.products[] | {id, name, category, selling_price, cost_price, stock}'
    
else
    echo "❌ Authentication failed, checking logs..."
    tail -10 /tmp/pos-backend.log
fi

echo ""
echo "✅ Fresh database setup completed!"
echo "🌐 Frontend: http://localhost:3001"
echo "🔑 Login: admin/admin123 or kasir/kasir123"
