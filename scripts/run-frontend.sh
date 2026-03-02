#!/bin/bash

echo "🔄 Membersihkan port yang digunakan..."
lsof -ti:3000 | xargs kill -9 2>/dev/null
sleep 1

echo "✅ Port sudah dibersihkan"
echo ""
echo "🎨 Menjalankan frontend..."
cd frontend
npm run dev
