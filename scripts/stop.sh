#!/bin/bash

echo "🛑 Stopping POS UMKM System..."

# Stop Backend
BACKEND_PIDS=$(lsof -ti :8082)
if [ -n "$BACKEND_PIDS" ]; then
    kill -9 $BACKEND_PIDS 2>/dev/null
    echo "✅ Backend stopped"
else
    echo "ℹ️  Backend not running"
fi

# Stop Frontend
FRONTEND_PIDS=$(pgrep -f "vite.*pos-umkm")
if [ -n "$FRONTEND_PIDS" ]; then
    kill -9 $FRONTEND_PIDS 2>/dev/null
    echo "✅ Frontend stopped"
else
    echo "ℹ️  Frontend not running"
fi

echo "✅ System stopped"
