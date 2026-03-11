#!/bin/bash

# Production build script
# Builds both frontend and backend for production deployment

echo "🏗️  Building POS UMKM for Production"
echo "====================================="
echo ""

# Build Frontend
echo "📦 Building Frontend..."
cd frontend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Build
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Frontend build successful"
    echo "📁 Output: frontend/dist/"
else
    echo "❌ Frontend build failed"
    exit 1
fi

cd ..

# Build Backend
echo ""
echo "🔧 Building Backend..."
cd backend

# Download dependencies
go mod download

# Build binary
go build -o pos-umkm-server -ldflags="-s -w" main.go

if [ $? -eq 0 ]; then
    echo "✅ Backend build successful"
    echo "📁 Output: backend/pos-umkm-server"
else
    echo "❌ Backend build failed"
    exit 1
fi

cd ..

echo ""
echo "✨ Build Complete!"
echo "=================="
echo ""
echo "Production files:"
echo "  Frontend: frontend/dist/"
echo "  Backend:  backend/pos-umkm-server"
echo ""
echo "Deployment instructions:"
echo "1. Copy frontend/dist/ to your web server"
echo "2. Copy backend/pos-umkm-server to your server"
echo "3. Copy backend/.env and update for production"
echo "4. Run: ./pos-umkm-server"
echo ""
echo "⚠️  Remember to:"
echo "  - Update CORS origins in backend"
echo "  - Use HTTPS in production"
echo "  - Set strong JWT_SECRET"
echo "  - Use secure database password"
