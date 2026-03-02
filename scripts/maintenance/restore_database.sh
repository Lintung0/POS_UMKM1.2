#!/bin/bash

# Database Restore Script for POS UMKM
# Usage: ./restore_database.sh <backup_file>

if [ -z "$1" ]; then
    echo "❌ Error: Backup file not specified"
    echo "Usage: ./restore_database.sh <backup_file>"
    echo ""
    echo "Available backups:"
    ls -lh ./backups/pos_umkm_backup_*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"
DB_NAME="pos_umkm"
DB_USER="root"
DB_PASS="root"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "⚠️  WARNING: This will replace all current data!"
echo "📁 Backup file: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to restore? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 0
fi

echo "🔄 Starting database restore..."

# Decompress if gzipped
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo "📦 Decompressing backup..."
    gunzip -c "$BACKUP_FILE" | docker exec -i monorepo-devenv-mysql mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" 2>/dev/null
else
    docker exec -i monorepo-devenv-mysql mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$BACKUP_FILE" 2>/dev/null
fi

if [ $? -eq 0 ]; then
    echo "✅ Database restored successfully!"
else
    echo "❌ Restore failed!"
    exit 1
fi
