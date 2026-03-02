package config

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/mysql"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	dbType := os.Getenv("DB_TYPE")
	if dbType == "" {
		dbType = "mysql"
	}

	var database *gorm.DB
	var err error

	if dbType == "sqlite" {
		dbName := os.Getenv("DB_NAME")
		if dbName == "" {
			dbName = "pos_umkm.db"
		}

		log.Printf("🔗 Connecting to SQLite: %s", dbName)
		database, err = gorm.Open(sqlite.Open(dbName), &gorm.Config{
			PrepareStmt:                              true,
			DisableForeignKeyConstraintWhenMigrating: true,
		})

		if err != nil {
			log.Fatal("❌ SQLite connection failed: ", err)
		}
		log.Println("✅ SQLite connected")
	} else {
		// MySQL configuration
		dbHost := os.Getenv("DB_HOST")
		dbPort := os.Getenv("DB_PORT")
		dbUser := os.Getenv("DB_USER")
		dbPassword := os.Getenv("DB_PASSWORD")
		dbName := os.Getenv("DB_NAME")

		if dbHost == "" {
			dbHost = "localhost"
		}
		if dbPort == "" {
			dbPort = "3306"
		}
		if dbUser == "" {
			dbUser = "root"
		}
		if dbName == "" {
			dbName = "pos_umkm"
		}

		dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
			dbUser, dbPassword, dbHost, dbPort, dbName)

		log.Printf("🔗 MySQL: %s@%s:%s/%s", dbUser, dbHost, dbPort, dbName)

		database, err = gorm.Open(mysql.Open(dsn), &gorm.Config{
			PrepareStmt:                              true,
			DisableForeignKeyConstraintWhenMigrating: false,
			CreateBatchSize:                          1000,
		})

		if err != nil {
			log.Fatal("❌ MySQL connection failed: ", err)
		}
		log.Println("✅ MySQL connected")
	}

	DB = database
}
