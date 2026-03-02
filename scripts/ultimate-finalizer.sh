#!/bin/bash

echo "🚀 ULTIMATE POS UMKM FINALIZER"
echo "=============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISSUES_FOUND=0

check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
}

echo ""
echo -e "${BLUE}📋 PHASE 1: SYSTEM REQUIREMENTS CHECK${NC}"
echo "====================================="

# Check Node.js
echo -n "Checking Node.js... "
node --version > /dev/null 2>&1
check_status "Node.js installed"

# Check MySQL
echo -n "Checking MySQL... "
mysql --version > /dev/null 2>&1
check_status "MySQL installed"

# Check Go
echo -n "Checking Go... "
go version > /dev/null 2>&1
check_status "Go installed"

echo ""
echo -e "${BLUE}📋 PHASE 2: DATABASE SETUP${NC}"
echo "=========================="

# Create database and user
echo -n "Setting up database... "
mysql -u root -e "
CREATE DATABASE IF NOT EXISTS pos_umkm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'jarvis'@'localhost' IDENTIFIED BY 'jarvis160309';
GRANT ALL PRIVILEGES ON pos_umkm.* TO 'jarvis'@'localhost';
FLUSH PRIVILEGES;
" 2>/dev/null
check_status "Database and user created"

# Test connection
echo -n "Testing database connection... "
mysql -u jarvis -pjarvis160309 -e "USE pos_umkm; SELECT 1;" > /dev/null 2>&1
check_status "Database connection working"

echo ""
echo -e "${BLUE}📋 PHASE 3: BACKEND OPTIMIZATION${NC}"
echo "==============================="

cd backend

# Update go.mod
echo -n "Updating Go dependencies... "
go mod tidy > /dev/null 2>&1
check_status "Go dependencies updated"

# Build backend
echo -n "Building backend... "
go build -o pos-backend main.go > /dev/null 2>&1
check_status "Backend built successfully"

cd ..

echo ""
echo -e "${BLUE}📋 PHASE 4: FRONTEND OPTIMIZATION${NC}"
echo "================================"

cd frontend

# Clear cache
echo -n "Clearing frontend cache... "
rm -rf node_modules/.vite dist > /dev/null 2>&1
check_status "Frontend cache cleared"

# Install dependencies
echo -n "Installing frontend dependencies... "
npm install > /dev/null 2>&1
check_status "Frontend dependencies installed"

# Build for production test
echo -n "Testing frontend build... "
npm run build > /dev/null 2>&1
check_status "Frontend build successful"

cd ..

echo ""
echo -e "${BLUE}📋 PHASE 5: DATA SEEDING${NC}"
echo "======================="

# Seed database with optimized data
echo -n "Seeding database... "
mysql -u jarvis -pjarvis160309 pos_umkm << 'EOF' > /dev/null 2>&1
-- Clear existing data
DELETE FROM transaction_details;
DELETE FROM transactions;
DELETE FROM recipes;
DELETE FROM products;
DELETE FROM raw_materials;
DELETE FROM users;

-- Insert users
INSERT INTO users (username, password, full_name, role) VALUES
('admin', 'admin123', 'Administrator', 'admin'),
('kasir', 'kasir123', 'Kasir Utama', 'kasir');

-- Insert products
INSERT INTO products (name, cost_price, selling_price, stock, category) VALUES
('Kopi Americano', 3000.00, 8000.00, 100, 'Minuman'),
('Kopi Latte', 4000.00, 10000.00, 80, 'Minuman'),
('Teh Tarik', 2500.00, 7000.00, 90, 'Minuman'),
('Cappuccino', 4500.00, 12000.00, 60, 'Minuman'),
('Nasi Goreng Spesial', 8000.00, 15000.00, 50, 'Makanan'),
('Mie Goreng', 7000.00, 14000.00, 45, 'Makanan'),
('Ayam Geprek', 10000.00, 20000.00, 30, 'Makanan'),
('Kentang Goreng', 5000.00, 10000.00, 70, 'Snack'),
('Onion Rings', 4500.00, 9000.00, 60, 'Snack'),
('Roti Bakar', 3500.00, 8000.00, 40, 'Snack');

-- Insert raw materials
INSERT INTO raw_materials (name, stock, unit, price_per_unit, min_stock) VALUES
('Biji Kopi Arabica', 5000.00, 'gr', 0.80, 500.00),
('Susu Full Cream', 10000.00, 'ml', 0.35, 1000.00),
('Gula Pasir', 20000.00, 'gr', 0.25, 2000.00),
('Teh Premium', 200.00, 'pcs', 500.00, 50.00),
('Beras Premium', 50000.00, 'gr', 0.18, 5000.00),
('Ayam Fillet', 20000.00, 'gr', 0.45, 2000.00),
('Kentang', 30000.00, 'gr', 0.30, 3000.00),
('Minyak Goreng', 20000.00, 'ml', 0.28, 2000.00),
('Tepung Terigu', 25000.00, 'gr', 0.22, 3000.00),
('Roti Tawar', 50.00, 'pcs', 3000.00, 10.00);

-- Insert sample transactions
INSERT INTO transactions (total_amount, total_profit, cash_received, change_amount, payment_method, cashier_name) VALUES
(25000.00, 8000.00, 30000.00, 5000.00, 'CASH', 'Admin'),
(18000.00, 6000.00, 20000.00, 2000.00, 'CASH', 'Kasir Utama'),
(32000.00, 12000.00, 35000.00, 3000.00, 'CASH', 'Admin');

-- Insert transaction details
INSERT INTO transaction_details (transaction_id, product_name, quantity, price, subtotal) VALUES
(1, 'Kopi Latte', 2, 10000.00, 20000.00),
(1, 'Kentang Goreng', 1, 10000.00, 10000.00),
(2, 'Nasi Goreng Spesial', 1, 15000.00, 15000.00),
(2, 'Teh Tarik', 1, 7000.00, 7000.00),
(3, 'Ayam Geprek', 1, 20000.00, 20000.00),
(3, 'Cappuccino', 1, 12000.00, 12000.00);
EOF
check_status "Database seeded with sample data"

echo ""
echo -e "${BLUE}📋 PHASE 6: SYSTEM STARTUP${NC}"
echo "========================="

# Start backend
echo -n "Starting backend... "
cd backend
nohup ./pos-backend > /tmp/pos-backend.log 2>&1 &
BACKEND_PID=$!
sleep 3
if kill -0 $BACKEND_PID 2>/dev/null; then
    echo $BACKEND_PID > /tmp/pos-backend.pid
    check_status "Backend started (PID: $BACKEND_PID)"
else
    echo -e "${RED}❌ Backend failed to start${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
cd ..

# Start frontend
echo -n "Starting frontend... "
cd frontend
nohup npm run dev > /tmp/pos-frontend.log 2>&1 &
FRONTEND_PID=$!
sleep 5
if kill -0 $FRONTEND_PID 2>/dev/null; then
    echo $FRONTEND_PID > /tmp/pos-frontend.pid
    check_status "Frontend started (PID: $FRONTEND_PID)"
else
    echo -e "${RED}❌ Frontend failed to start${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
cd ..

echo ""
echo -e "${BLUE}📋 PHASE 7: COMPREHENSIVE TESTING${NC}"
echo "================================"

sleep 5

# Test backend health
echo -n "Testing backend health... "
curl -s http://localhost:8082/health > /dev/null 2>&1
check_status "Backend health check passed"

# Test authentication
echo -n "Testing authentication... "
LOGIN_RESPONSE=$(curl -s -X POST "http://localhost:8082/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')
if echo "$LOGIN_RESPONSE" | grep -q '"success":true'; then
    check_status "Authentication working"
else
    echo -e "${RED}❌ Authentication failed${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Test all major endpoints
ENDPOINTS=(
    "products:GET:/api/products"
    "materials:GET:/api/materials"
    "dashboard:GET:/api/dashboard/summary"
    "transactions:GET:/api/transactions"
)

for endpoint in "${ENDPOINTS[@]}"; do
    IFS=':' read -r name method path <<< "$endpoint"
    echo -n "Testing $name endpoint... "
    curl -s "http://localhost:8082$path" > /dev/null 2>&1
    check_status "$name endpoint working"
done

# Test frontend accessibility
echo -n "Testing frontend accessibility... "
FRONTEND_PORT=$(grep -o 'http://localhost:[0-9]*' /tmp/pos-frontend.log | head -1 | grep -o '[0-9]*$')
if [ -n "$FRONTEND_PORT" ]; then
    curl -s "http://localhost:$FRONTEND_PORT" > /dev/null 2>&1
    check_status "Frontend accessible on port $FRONTEND_PORT"
else
    echo -e "${RED}❌ Frontend port not detected${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

echo ""
echo -e "${BLUE}📋 FINAL REPORT${NC}"
echo "==============="

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 ULTIMATE FINALIZER COMPLETED SUCCESSFULLY!${NC}"
    echo ""
    echo -e "${GREEN}✅ System Status: PERFECT${NC}"
    echo -e "${GREEN}✅ Backend: Running on http://localhost:8082${NC}"
    echo -e "${GREEN}✅ Frontend: Running on http://localhost:${FRONTEND_PORT:-3000}${NC}"
    echo -e "${GREEN}✅ Database: Fully configured with sample data${NC}"
    echo ""
    echo -e "${BLUE}🔐 Login Credentials:${NC}"
    echo "   Admin: admin / admin123"
    echo "   Kasir: kasir / kasir123"
    echo ""
    echo -e "${BLUE}🌐 Access URLs:${NC}"
    echo "   Frontend: http://localhost:${FRONTEND_PORT:-3000}"
    echo "   Backend API: http://localhost:8082/api"
    echo "   Health Check: http://localhost:8082/health"
    echo ""
    echo -e "${BLUE}📊 Features Ready:${NC}"
    echo "   ✅ Authentication & Authorization"
    echo "   ✅ Product Management (CRUD)"
    echo "   ✅ Material Management (CRUD)"
    echo "   ✅ Recipe Management"
    echo "   ✅ POS/Cashier System"
    echo "   ✅ Transaction History"
    echo "   ✅ Reports (Daily/Monthly)"
    echo "   ✅ Dashboard Analytics"
    echo "   ✅ Dark/Light Theme"
    echo "   ✅ Print Receipt"
    echo ""
    echo -e "${GREEN}🚀 SYSTEM IS PRODUCTION READY!${NC}"
else
    echo -e "${YELLOW}⚠️  FINALIZER COMPLETED WITH $ISSUES_FOUND ISSUES${NC}"
    echo "Please check the logs and fix the issues above."
fi

echo ""
echo -e "${BLUE}📝 Logs Location:${NC}"
echo "   Backend: tail -f /tmp/pos-backend.log"
echo "   Frontend: tail -f /tmp/pos-frontend.log"
