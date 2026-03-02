#!/bin/bash

# ============================================
# CORS TEST & FIX SCRIPT
# ============================================

echo "🔧 Testing CORS Fix..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if backend is running
if ! curl -s http://localhost:8081/health > /dev/null; then
    echo -e "${YELLOW}⚠️  Backend not running. Starting backend...${NC}"
    cd backend
    
    # Create .env if not exists
    if [ ! -f ".env" ]; then
        echo "DB_TYPE=sqlite" > .env
        echo "DB_NAME=pos_umkm.db" >> .env
        echo "JWT_SECRET=your_secret_key_here" >> .env
        echo "SERVER_PORT=8081" >> .env
        echo -e "${GREEN}✅ Created .env file${NC}"
    fi
    
    # Start backend in background
    go run main.go &
    BACKEND_PID=$!
    echo -e "${GREEN}✅ Backend started (PID: $BACKEND_PID)${NC}"
    
    # Wait for backend to start
    sleep 3
    cd ..
else
    echo -e "${GREEN}✅ Backend already running${NC}"
fi

# Test CORS
echo "🧪 Testing CORS headers..."

# Test OPTIONS request
echo "Testing OPTIONS request:"
curl -X OPTIONS \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v http://localhost:8081/api/dashboard/summary 2>&1 | grep -E "(Access-Control|HTTP/1.1)"

echo ""

# Test GET request
echo "Testing GET request:"
curl -X GET \
  -H "Origin: http://localhost:3000" \
  -v http://localhost:8081/api/dashboard/summary 2>&1 | grep -E "(Access-Control|HTTP/1.1)"

echo ""
echo -e "${GREEN}🎉 CORS test completed!${NC}"
echo ""
echo "If you see 'Access-Control-Allow-Origin: *' in the output above, CORS is working!"
echo ""
echo "To stop backend: kill $BACKEND_PID"
