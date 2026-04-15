package main

import (
	"backend/config"
	"backend/models"
	"backend/routes"
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func main() {
	// load env
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	config.ConnectDatabase()

	db := config.DB
	migrateModels(db)
	seedDefaultUsers(db)
	seedDefaultData(db)

	log.Println("✅ Database migration completed")

	// setup routes
	router := routes.SetupRouter()

	// Get port from env or default port
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8081"
	}

	log.Printf("🚀 Server starting on http://localhost:%s", port)
	log.Printf("📊 API Health Check: http://localhost:%s/health", port)
	log.Printf("🔗 API Base URL: http://localhost:%s/api", port)
	log.Printf("🕐 Server Time: %s", time.Now().Format("2006-01-02 15:04:05"))

	// Create HTTP server
	srv := &http.Server{
		Addr:           ":" + port,
		Handler:        router,
		ReadTimeout:    15 * time.Second,
		WriteTimeout:   15 * time.Second,
		IdleTimeout:    60 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}

	// Start server in goroutine
	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatal("❌ Failed to start server:", err)
		}
	}()

	log.Println("✅ Server started successfully")

	// Wait for interrupt signal for graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("🛑 Shutting down server...")

	// Graceful shutdown with 5 second timeout
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("❌ Server forced to shutdown:", err)
	}

	log.Println("✅ Server exited properly")
}

func migrateModels(db *gorm.DB) {
	log.Println("🔄 Starting database migration...")

	// First, migrate models without foreign key constraints
	log.Println("📋 Step 1: Migrating base models...")
	baseModels := []interface{}{
		&models.User{},
		&models.Product{},
		&models.RawMaterial{},
		&models.Transaction{},
		&models.AuditLog{},
	}

	for _, model := range baseModels {
		if err := db.AutoMigrate(model); err != nil {
			log.Printf("❌ Failed to migrate model %T: %v", model, err)
		} else {
			log.Printf("✅ Migrated model %T successfully", model)
		}
	}

	// Clean up any invalid data before adding foreign keys
	log.Println("🧹 Step 2: Cleaning invalid data...")
	db.Exec("DELETE FROM recipes WHERE product_id NOT IN (SELECT id FROM products)")
	db.Exec("DELETE FROM recipes WHERE material_id NOT IN (SELECT id FROM raw_materials)")
	db.Exec("DELETE FROM transaction_details WHERE transaction_id NOT IN (SELECT id FROM transactions)")
	db.Exec("DELETE FROM transaction_details WHERE product_id NOT IN (SELECT id FROM products)")

	// Now migrate models with foreign key constraints
	log.Println("🔗 Step 3: Migrating models with foreign keys...")
	relationModels := []interface{}{
		&models.Recipe{},
		&models.TransactionDetail{},
	}

	for _, model := range relationModels {
		if err := db.AutoMigrate(model); err != nil {
			log.Printf("❌ Failed to migrate model %T: %v", model, err)
			// Continue with other models even if one fails
		} else {
			log.Printf("✅ Migrated model %T successfully", model)
		}
	}

	// Add custom indexes and constraints
	addCustomConstraints(db)

	log.Println("✅ Database migration completed")
}

func addCustomConstraints(db *gorm.DB) {
	log.Println("🔧 Adding custom database constraints...")

	// Add unique constraint for recipes (prevent duplicate product-material combinations)
	if err := db.Exec(`
		ALTER TABLE recipes 
		ADD CONSTRAINT uk_recipe_product_material 
		UNIQUE (product_id, material_id)
	`).Error; err != nil {
		if !strings.Contains(err.Error(), "Duplicate") && !strings.Contains(err.Error(), "1061") {
			log.Printf("⚠️  Constraint warning: %v", err)
		}
	}

	// Add check constraints for positive values (MySQL 8.0+)
	constraints := map[string]string{
		"chk_positive_prices_v2":   "ALTER TABLE products ADD CONSTRAINT chk_positive_prices_v2 CHECK (cost_price >= 0 AND selling_price >= 0 AND stock >= 0)",
		"chk_positive_stock_v2":    "ALTER TABLE raw_materials ADD CONSTRAINT chk_positive_stock_v2 CHECK (stock >= 0 AND price_per_unit >= 0)",
		"chk_positive_quantity_v2": "ALTER TABLE recipes ADD CONSTRAINT chk_positive_quantity_v2 CHECK (quantity_used > 0)",
		"chk_positive_amounts_v2":  "ALTER TABLE transactions ADD CONSTRAINT chk_positive_amounts_v2 CHECK (total_amount >= 0 AND cash_received >= 0)",
		"chk_positive_qty_v2":      "ALTER TABLE transaction_details ADD CONSTRAINT chk_positive_qty_v2 CHECK (qty > 0 AND price_per_unit >= 0)",
	}

	for _, constraint := range constraints {
		if err := db.Exec(constraint).Error; err != nil {
			if !strings.Contains(err.Error(), "Duplicate") && !strings.Contains(err.Error(), "3822") {
				log.Printf("⚠️  Constraint warning: %v", err)
			}
		}
	}

	log.Println("✅ Custom constraints added")
}

func seedDefaultUsers(db *gorm.DB) {
	// Check if users already exist
	var userCount int64
	db.Model(&models.User{}).Count(&userCount)

	if userCount > 0 {
		log.Println("👥 Users already exist, skipping seeder")
		return
	}

	// Hash passwords
	adminHash, _ := bcrypt.GenerateFromPassword([]byte("admin123"), bcrypt.DefaultCost)
	cashierHash, _ := bcrypt.GenerateFromPassword([]byte("kasir123"), bcrypt.DefaultCost)

	// Create default users
	users := []models.User{
		{
			Username: "admin",
			Password: string(adminHash),
			FullName: "Administrator",
			Role:     "admin",
			IsActive: true,
		},
		{
			Username: "kasir",
			Password: string(cashierHash),
			FullName: "Kasir",
			Role:     "cashier",
			IsActive: true,
		},
	}

	for _, user := range users {
		if err := db.Session(&gorm.Session{SkipHooks: true}).Create(&user).Error; err != nil {
			log.Printf("❌ Failed to create user %s: %v", user.Username, err)
		} else {
			log.Printf("✅ Created user: %s (%s)", user.Username, user.Role)
		}
	}
}

func seedDefaultData(db *gorm.DB) {
	// Check if data already exists
	var materialCount, productCount int64
	db.Model(&models.RawMaterial{}).Count(&materialCount)
	db.Model(&models.Product{}).Count(&productCount)

	if materialCount > 0 && productCount > 0 {
		log.Println("📦 Default data already exists, skipping seeder")
		return
	}

	log.Println("📦 Seeding default data...")

	// Seed raw materials
	materials := []models.RawMaterial{
		{
			Name:         "Biji Kopi Arabica",
			Stock:        5000,
			Unit:         "gram",
			PricePerUnit: 30,
			MinStock:     500,
			Supplier:     "Supplier Kopi Lokal",
		},
		{
			Name:         "Susu UHT",
			Stock:        3000,
			Unit:         "ml",
			PricePerUnit: 12,
			MinStock:     300,
			Supplier:     "Dairy Farm",
		},
		{
			Name:         "Gula Pasir",
			Stock:        2000,
			Unit:         "gram",
			PricePerUnit: 15,
			MinStock:     200,
			Supplier:     "Pabrik Gula",
		},
		{
			Name:         "Teh Celup",
			Stock:        500,
			Unit:         "pieces",
			PricePerUnit: 500,
			MinStock:     50,
			Supplier:     "Tea Garden",
		},
		{
			Name:         "Tepung Terigu",
			Stock:        10000,
			Unit:         "gram",
			PricePerUnit: 8,
			MinStock:     1000,
			Supplier:     "Pabrik Tepung",
		},
	}

	for _, material := range materials {
		if err := db.Create(&material).Error; err != nil {
			log.Printf("❌ Failed to create material %s: %v", material.Name, err)
		} else {
			log.Printf("✅ Created material: %s", material.Name)
		}
	}

	// Seed products
	products := []models.Product{
		{
			Name:         "Kopi Susu Premium",
			CostPrice:    8000,
			SellingPrice: 15000,
			Stock:        50,
			Category:     "Minuman",
		},
		{
			Name:         "Teh Tarik Manis",
			CostPrice:    5000,
			SellingPrice: 12000,
			Stock:        40,
			Category:     "Minuman",
		},
		{
			Name:         "Cappuccino",
			CostPrice:    10000,
			SellingPrice: 18000,
			Stock:        30,
			Category:     "Minuman",
		},
		{
			Name:         "Roti Bakar Coklat",
			CostPrice:    6000,
			SellingPrice: 12000,
			Stock:        25,
			Category:     "Makanan",
		},
		{
			Name:         "Kentang Goreng",
			CostPrice:    8000,
			SellingPrice: 15000,
			Stock:        35,
			Category:     "Snack",
		},
	}

	for _, product := range products {
		if err := db.Create(&product).Error; err != nil {
			log.Printf("❌ Failed to create product %s: %v", product.Name, err)
		} else {
			log.Printf("✅ Created product: %s", product.Name)
		}
	}

	log.Println("✅ Default data seeding completed")
}
