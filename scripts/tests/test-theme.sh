#!/bin/bash

echo "🧪 Testing Theme Functionality..."
echo "================================"

# Check if frontend is running
if curl -s http://localhost:3001 > /dev/null; then
    echo "✅ Frontend is running at http://localhost:3001"
else
    echo "❌ Frontend is not accessible"
    exit 1
fi

echo ""
echo "📋 Test Instructions:"
echo "1. Open browser and go to: http://localhost:3001"
echo "2. Login with credentials:"
echo "   - Username: admin"
echo "   - Password: admin123"
echo "3. Navigate to Settings (Pengaturan)"
echo "4. Click on 'Tampilan' tab"
echo "5. Test theme switching:"
echo "   - Click 'Dark' theme - should change to dark mode"
echo "   - Click 'Light' theme - should change back to light mode"
echo "6. Refresh page - theme should persist"
echo ""
echo "🔧 Theme Fix Applied:"
echo "- Fixed ThemeContext to properly remove/add classes"
echo "- Simplified theme switching in SettingsPage"
echo "- Added proper class management for theme persistence"
echo ""
echo "🌐 Open browser now: http://localhost:3001"
