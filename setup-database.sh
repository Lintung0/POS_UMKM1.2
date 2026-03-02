#!/bin/bash

# ============================================
# POS UMKM - Safe Database Setup Script
# ============================================

echo "🚀 Setting up POS UMKM Database..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database configuration
DB_NAME="pos_umkm"
DB_USER="root"
DB_HOST="localhost"
DB_PORT="3306"

# Function to check MySQL connection
check_mysql() {
    echo "🔍 Checking MySQL connection..."
    if ! command -v mysql &> /dev/null; then
        echo -e "${RED}❌ MySQL client not found. Please install MySQL.${NC}"
        exit 1
    fi
    
    if ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p -e "SELECT 1;" &> /dev/null; then
        echo -e "${RED}❌ Cannot connect to MySQL. Please check your credentials.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ MySQL connection successful${NC}"
}

# Function to create database
create_database() {
    echo "📦 Creating database..."
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p -e "
        CREATE DATABASE IF NOT EXISTS $DB_NAME 
        CHARACTER SET utf8mb4 
        COLLATE utf8mb4_unicode_ci;
        
        USE $DB_NAME;
        
        SELECT 'Database $DB_NAME created successfully' as status;
    "
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Database created successfully${NC}"
    else
        echo -e "${RED}❌ Failed to create database${NC}"
        exit 1
    fi
}

# Function to run initial schema
run_initial_schema() {
    echo "🏗️  Running initial schema..."
    if [ -f "database/init.sql" ]; then
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p "$DB_NAME" < database/init.sql
        echo -e "${GREEN}✅ Initial schema applied${NC}"
    else
        echo -e "${YELLOW}⚠️  init.sql not found, skipping...${NC}"
    fi
}

# Function to add foreign keys
add_foreign_keys() {
    echo "🔗 Adding foreign key constraints..."
    if [ -f "database/add_foreign_keys.sql" ]; then
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p "$DB_NAME" < database/add_foreign_keys.sql
        echo -e "${GREEN}✅ Foreign keys added${NC}"
    else
        echo -e "${YELLOW}⚠️  add_foreign_keys.sql not found, skipping...${NC}"
    fi
}

# Function to create .env file
create_env_file() {
    echo "⚙️  Creating .env file..."
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            echo -e "${GREEN}✅ .env file created from template${NC}"
            echo -e "${YELLOW}⚠️  Please edit .env file with your database password${NC}"
        else
            echo -e "${RED}❌ .env.example not found${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  .env file already exists${NC}"
    fi
}

# Function to test backend compilation
test_backend() {
    echo "🧪 Testing backend compilation..."
    cd backend
    if go mod tidy && go build -o pos_backend .; then
        echo -e "${GREEN}✅ Backend compiles successfully${NC}"
        rm -f pos_backend
    else
        echo -e "${RED}❌ Backend compilation failed${NC}"
        exit 1
    fi
    cd ..
}

# Function to test frontend dependencies
test_frontend() {
    echo "🧪 Testing frontend dependencies..."
    cd frontend
    if [ -f "package.json" ]; then
        if command -v npm &> /dev/null; then
            npm install --silent
            echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
        else
            echo -e "${YELLOW}⚠️  npm not found, skipping frontend test${NC}"
        fi
    fi
    cd ..
}

# Main execution
main() {
    echo "============================================"
    echo "🏪 POS UMKM - Database Setup"
    echo "============================================"
    
    # Check if we're in the right directory
    if [ ! -f "backend/main.go" ]; then
        echo -e "${RED}❌ Please run this script from the POS_UMKM-master directory${NC}"
        exit 1
    fi
    
    # Run setup steps
    check_mysql
    create_database
    run_initial_schema
    add_foreign_keys
    create_env_file
    test_backend
    test_frontend
    
    echo ""
    echo "============================================"
    echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
    echo "============================================"
    echo ""
    echo "Next steps:"
    echo "1. Edit .env file with your database password"
    echo "2. Run: cd backend && go run main.go"
    echo "3. In another terminal: cd frontend && npm run dev"
    echo ""
    echo "Default login:"
    echo "Username: admin"
    echo "Password: admin123"
    echo ""
}

# Run main function
main
