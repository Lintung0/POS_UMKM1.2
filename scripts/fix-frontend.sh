#!/bin/bash

echo "🔧 Fixing Frontend Display Issue..."
echo "=================================="

# Stop current processes
cd /home/kirek/code/pos-umkm
./stop.sh

# Clear any cached files
echo "🧹 Clearing cache..."
rm -rf frontend/node_modules/.vite
rm -rf frontend/dist

# Restart with fresh state
echo "🚀 Starting fresh..."
./start.sh

echo ""
echo "✅ System restarted!"
echo "🌐 Try accessing: http://localhost:3000 or http://localhost:3001"
echo ""
echo "If still not working, try:"
echo "1. Clear browser cache (Ctrl+Shift+Delete)"
echo "2. Open browser developer tools (F12) and check console for errors"
echo "3. Try incognito/private browsing mode"
