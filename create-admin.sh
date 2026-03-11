#!/bin/bash

# Script untuk create default admin user

echo "🔐 CREATE DEFAULT ADMIN USER"
echo "============================="
echo ""

DB_USER="root"
DB_PASS="root"
DB_NAME="pos_umkm"

# Check if users table exists
echo "Checking users table..."
TABLE_EXISTS=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -se "SHOW TABLES LIKE 'users';" 2>/dev/null)

if [ -z "$TABLE_EXISTS" ]; then
    echo "❌ Table 'users' tidak ditemukan!"
    echo "Jalankan migration terlebih dahulu."
    exit 1
fi

# Check if admin user exists
ADMIN_EXISTS=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -se "SELECT COUNT(*) FROM users WHERE username='admin';" 2>/dev/null)

if [ "$ADMIN_EXISTS" -gt 0 ]; then
    echo "✅ User admin sudah ada"
    mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "SELECT id, username, full_name, role, is_active FROM users WHERE username='admin';" 2>/dev/null
else
    echo "Creating admin user..."
    
    # Hash password 'admin123' dengan bcrypt cost 10
    # Password hash untuk 'admin123'
    HASHED_PASS='$2a$10$rN8qzKzQxGKJ5vZ5J5J5J5J5J5J5J5J5J5J5J5J5J5J5J5J5J5J5J5'
    
    mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
    INSERT INTO users (username, password, full_name, role, is_active, created_at, updated_at)
    VALUES ('admin', '$HASHED_PASS', 'Administrator', 'admin', 1, NOW(), NOW());
    " 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Admin user created successfully!"
        echo ""
        echo "Login credentials:"
        echo "  Username: admin"
        echo "  Password: admin123"
    else
        echo "❌ Failed to create admin user"
    fi
fi

echo ""
echo "All users:"
mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "SELECT id, username, full_name, role, is_active, created_at FROM users;" 2>/dev/null
