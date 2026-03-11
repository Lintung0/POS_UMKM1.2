#!/bin/bash

# Setup script untuk POS UMKM
# Script ini akan membantu setup environment

echo "🔧 POS UMKM - Environment Setup"
echo "================================"
echo ""

# Check Node.js
echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo "✅ Node.js installed: $NODE_VERSION"
else
    echo "❌ Node.js not found. Please install Node.js first."
    exit 1
fi

# Check npm
echo "Checking npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm -v)
    echo "✅ npm installed: $NPM_VERSION"
else
    echo "❌ npm not found. Please install npm first."
    exit 1
fi

# Check Go
echo "Checking Go..."
if command -v go &> /dev/null; then
    GO_VERSION=$(go version)
    echo "✅ Go installed: $GO_VERSION"
else
    echo "❌ Go not found. Please install Go first."
    exit 1
fi

# Check MySQL
echo "Checking MySQL..."
if command -v mysql &> /dev/null; then
    MYSQL_VERSION=$(mysql --version)
    echo "✅ MySQL installed: $MYSQL_VERSION"
else
    echo "❌ MySQL not found. Please install MySQL first."
    exit 1
fi

echo ""
echo "📦 Installing dependencies..."
echo ""

# Install frontend dependencies
echo "Installing frontend dependencies..."
cd frontend
if [ ! -d "node_modules" ]; then
    npm install
    if [ $? -eq 0 ]; then
        echo "✅ Frontend dependencies installed"
    else
        echo "❌ Failed to install frontend dependencies"
        exit 1
    fi
else
    echo "✅ Frontend dependencies already installed"
fi
cd ..

# Install backend dependencies
echo "Installing backend dependencies..."
cd backend
go mod download
if [ $? -eq 0 ]; then
    echo "✅ Backend dependencies installed"
else
    echo "❌ Failed to install backend dependencies"
    exit 1
fi
cd ..

echo ""
echo "🗄️  Database Setup"
echo "=================="
echo ""

# Check if .env exists
if [ ! -f "backend/.env" ]; then
    echo "⚠️  backend/.env not found. Creating from .env.example..."
    if [ -f "backend/.env.example" ]; then
        cp backend/.env.example backend/.env
        echo "✅ Created backend/.env"
        echo "⚠️  Please update database credentials in backend/.env"
    else
        echo "❌ backend/.env.example not found"
    fi
else
    echo "✅ backend/.env exists"
fi

# Ask if user wants to create database
echo ""
read -p "Do you want to create the database now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter MySQL root password: " -s MYSQL_PASSWORD
    echo ""
    
    # Create database
    mysql -u root -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS pos_umkm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Database 'pos_umkm' created"
        
        # Import schema if exists
        if [ -f "database/schema.sql" ]; then
            read -p "Import database schema? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                mysql -u root -p"$MYSQL_PASSWORD" pos_umkm < database/schema.sql 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo "✅ Database schema imported"
                else
                    echo "❌ Failed to import schema"
                fi
            fi
        fi
    else
        echo "❌ Failed to create database. Please check your MySQL credentials."
    fi
fi

echo ""
echo "✨ Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "1. Update backend/.env with your database credentials"
echo "2. Run './start-app.sh' to start the application"
echo "3. Open http://localhost:3000 in your browser"
echo ""
echo "For more information, see PRODUCTION_CHECKLIST.md"
