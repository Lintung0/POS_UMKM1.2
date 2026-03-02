#!/bin/bash

echo "🔄 Membersihkan port yang digunakan..."
lsof -ti:8082 | xargs kill -9 2>/dev/null
sleep 1

echo "✅ Port sudah dibersihkan"
echo ""
echo "🚀 Menjalankan backend..."
cd backend

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  File .env tidak ditemukan, menggunakan konfigurasi default"
fi

go run main.go
