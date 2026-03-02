#!/bin/bash

echo "🔄 Restarting frontend to apply optimizations..."

# Kill existing frontend process
pkill -f "vite" 2>/dev/null || true

# Wait a moment
sleep 2

# Start frontend in background
cd frontend
nohup npm run dev > ../frontend.log 2>&1 &

echo "✅ Frontend restarted with optimized CRUD and dark theme"
echo "📱 Frontend: http://localhost:3000"
echo "🔗 Backend: http://localhost:8082"
echo "📋 Logs: tail -f frontend.log"
