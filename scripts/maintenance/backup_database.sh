#!/bin/bash

# Database Backup Script for POS UMKM
# Usage: ./backup_database.sh

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="./backups"
DB_NAME="pos_umkm"
DB_USER="root"
DB_PASS="root"
DB_HOST="127.0.0.1"
DB_PORT="3306"

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Backup filename
BACKUP_FILE="$BACKUP_DIR/pos_umkm_backup_$TIMESTAMP.sql"

echo "🔄 Starting database backup..."
echo "📅 Timestamp: $TIMESTAMP"

# Perform backup using docker
docker exec monorepo-devenv-mysql mysqldump \
    -u"$DB_USER" \
    -p"$DB_PASS" \
    "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
    # Compress backup
    gzip "$BACKUP_FILE"
    BACKUP_FILE="$BACKUP_FILE.gz"
    
    # Get file size
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    
    echo "✅ Backup completed successfully!"
    echo "📁 File: $BACKUP_FILE"
    echo "📊 Size: $SIZE"
    
    # Keep only last 7 backups
    echo "🧹 Cleaning old backups (keeping last 7)..."
    ls -t "$BACKUP_DIR"/pos_umkm_backup_*.sql.gz | tail -n +8 | xargs -r rm
    
    echo "✅ Backup process completed!"
else
    echo "❌ Backup failed!"
    exit 1
fi
