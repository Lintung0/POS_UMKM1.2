#!/bin/bash

echo "🔧 Quick Fix for Foreign Key Migration"
echo "======================================"

cd backend

# Create a temporary migration fix
cat > temp_migration_fix.go << 'EOF'
package main

import (
	"log"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"backend/models"
)

func main() {
	dsn := "root@tcp(127.0.0.1:3306)/pos_umkm?charset=utf8mb4&parseTime=True&loc=Local"
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect:", err)
	}

	log.Println("🔧 Dropping existing foreign key constraints...")
	
	// Drop existing constraints that might be causing issues
	db.Exec("ALTER TABLE recipes DROP FOREIGN KEY IF EXISTS fk_raw_materials_recipes")
	db.Exec("ALTER TABLE recipes DROP FOREIGN KEY IF EXISTS fk_products_recipes")
	db.Exec("ALTER TABLE transaction_details DROP FOREIGN KEY IF EXISTS fk_transactions_details")
	db.Exec("ALTER TABLE transaction_details DROP FOREIGN KEY IF EXISTS fk_products_transaction_details")
	
	log.Println("🔄 Re-running AutoMigrate...")
	
	// Re-migrate models
	err = db.AutoMigrate(
		&models.Recipe{},
		&models.TransactionDetail{},
	)
	
	if err != nil {
		log.Printf("❌ Migration error: %v", err)
	} else {
		log.Println("✅ Migration completed successfully!")
	}
}
EOF

echo "Running migration fix..."
go run temp_migration_fix.go

# Clean up
rm temp_migration_fix.go

echo "✅ Migration fix completed!"
echo "Now run: go run main.go"
