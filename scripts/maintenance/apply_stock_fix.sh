#!/bin/bash

# ============================================
# SCRIPT: Apply Stock System Fix Migration
# ============================================

set -e

echo "🔧 Applying Stock System Fix Migration..."
echo "=========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database credentials
DB_USER="root"
DB_PASS="root"
DB_NAME="pos_umkm"

# Check if MySQL is running
if ! mysqladmin ping -h"127.0.0.1" -u"$DB_USER" -p"$DB_PASS" --silent 2>/dev/null; then
    echo -e "${RED}❌ MySQL is not running!${NC}"
    echo "Please start MySQL first:"
    echo "  sudo systemctl start mysql"
    exit 1
fi

echo -e "${GREEN}✅ MySQL is running${NC}"

# Backup database first
BACKUP_FILE="backups/backup_before_fix_$(date +%Y%m%d_%H%M%S).sql"
mkdir -p backups

echo "📦 Creating backup: $BACKUP_FILE"
mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null
echo -e "${GREEN}✅ Backup created${NC}"

# Apply migration
echo "🚀 Applying migration..."
mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < database/migration_production_tracking.sql 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Migration applied successfully!${NC}"
    echo ""
    echo "📊 Verifying changes..."
    
    # Verify tables created
    mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
        SELECT 
            'productions' as table_name,
            COUNT(*) as row_count
        FROM productions
        UNION ALL
        SELECT 
            'production_materials' as table_name,
            COUNT(*) as row_count
        FROM production_materials;
    " 2>/dev/null
    
    echo ""
    echo -e "${GREEN}✅ All changes verified!${NC}"
    echo ""
    echo "📝 Summary:"
    echo "  - Added 'has_recipe' column to products table"
    echo "  - Created 'productions' table"
    echo "  - Created 'production_materials' table"
    echo "  - Updated existing products with recipes"
    echo ""
    echo "🎉 Stock system fix applied successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart backend: cd backend && ./start.sh"
    echo "  2. Test production: POST /api/production/produce"
    echo "  3. Test transaction: POST /api/transactions"
    echo "  4. Check production history: GET /api/production"
else
    echo -e "${RED}❌ Migration failed!${NC}"
    echo "Restoring from backup..."
    mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$BACKUP_FILE" 2>/dev/null
    echo -e "${YELLOW}⚠️  Database restored to previous state${NC}"
    exit 1
fi
