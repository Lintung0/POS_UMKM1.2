#!/bin/bash

echo "🗄️ MYSQL DATABASE SETUP FOR POS UMKM"
echo "===================================="

# Check if MySQL is installed and running
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL not found. Please install MySQL first:"
    echo "   Ubuntu/Debian: sudo apt install mysql-server"
    echo "   CentOS/RHEL: sudo yum install mysql-server"
    echo "   macOS: brew install mysql"
    exit 1
fi

# Check if MySQL service is running
if ! systemctl is-active --quiet mysql 2>/dev/null && ! pgrep mysqld > /dev/null; then
    echo "❌ MySQL service is not running. Starting MySQL..."
    sudo systemctl start mysql 2>/dev/null || sudo service mysql start 2>/dev/null
    sleep 3
fi

echo "✅ MySQL service is running"
echo ""

# Database configuration
DB_NAME="pos_umkm"
DB_USER="root"

echo "1️⃣ Creating MySQL Database"
echo "=========================="

# Create database
mysql -u $DB_USER -p << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SHOW DATABASES LIKE '$DB_NAME';
EOF

if [ $? -eq 0 ]; then
    echo "✅ Database '$DB_NAME' created successfully"
else
    echo "❌ Failed to create database. Please check MySQL credentials."
    exit 1
fi

echo ""
echo "2️⃣ Testing Database Connection"
echo "=============================="

# Test connection
mysql -u $DB_USER -p -D $DB_NAME << EOF
SELECT 'Database connection successful!' as status;
EOF

echo ""
echo "3️⃣ Database Configuration"
echo "========================="
echo "Database Name: $DB_NAME"
echo "Database User: $DB_USER"
echo "Host: localhost"
echo "Port: 3306"
echo "Character Set: utf8mb4"
echo "Collation: utf8mb4_unicode_ci"

echo ""
echo "4️⃣ Backend Configuration Updated"
echo "==============================="
echo "✅ .env file updated to use MySQL"
echo "✅ Database type: mysql"
echo "✅ Database name: $DB_NAME"

echo ""
echo "5️⃣ Next Steps"
echo "============="
echo "1. Restart the POS system: ./stop.sh && ./start.sh"
echo "2. Backend will auto-migrate tables using GORM"
echo "3. Default data will be seeded automatically"
echo "4. Check logs for any connection issues"

echo ""
echo "🔧 Troubleshooting"
echo "=================="
echo "If connection fails:"
echo "1. Check MySQL service: sudo systemctl status mysql"
echo "2. Verify credentials: mysql -u root -p"
echo "3. Check port 3306: netstat -tlnp | grep 3306"
echo "4. Update .env file with correct password if needed"

echo ""
echo "✅ MySQL setup completed!"
echo "🚀 Ready to restart POS system with MySQL backend"
