#!/bin/bash

echo "🚀 Starting POS UMKM System..."

# Start Backend
cd backend
echo "📦 Starting Backend..."
nohup go run main.go > /tmp/pos-backend.log 2>&1 &
BACKEND_PID=$!
echo "✅ Backend started (PID: $BACKEND_PID)"

# Wait for backend
sleep 3

# Start Frontend
cd ../frontend
echo "🎨 Starting Frontend..."
nohup npm run dev > /tmp/pos-frontend.log 2>&1 &
FRONTEND_PID=$!
echo "✅ Frontend started (PID: $FRONTEND_PID)"

# Wait for frontend
sleep 5

# Check status
echo ""
echo "📊 System Status:"
curl -s http://localhost:8082/health | jq . 2>/dev/null && echo "✅ Backend: http://localhost:8082" || echo "❌ Backend failed"

FRONTEND_PORT=$(grep -oP 'Local:\s+http://localhost:\K\d+' /tmp/pos-frontend.log | tail -1)
if [ -n "$FRONTEND_PORT" ]; then
    echo "✅ Frontend: http://localhost:$FRONTEND_PORT"
else
    echo "❌ Frontend failed"
fi

echo ""
echo "📝 Logs:"
echo "   Backend:  tail -f /tmp/pos-backend.log"
echo "   Frontend: tail -f /tmp/pos-frontend.log"
