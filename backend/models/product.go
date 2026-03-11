package models

import (
	"time"
	"gorm.io/gorm"
)

type Product struct {
	ID               uint                `gorm:"primaryKey" json:"id"`
    Name             string              `gorm:"size:100;not null;index" json:"name"`
    CostPrice        float64             `gorm:"type:decimal(10,2);not null" json:"cost_price"`
    SellingPrice     float64             `gorm:"type:decimal(10,2);not null" json:"selling_price"`
    Stock            int                 `gorm:"default:0" json:"stock"`
    Category         string              `gorm:"size:50;default:'Umum';index" json:"category"`
    Image            string              `gorm:"type:longtext" json:"image"`
    HasRecipe        bool                `gorm:"default:false" json:"has_recipe"`
    Recipes          []Recipe            `gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT" json:"recipes,omitempty"`
    TransactionDetails []TransactionDetail `gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT" json:"transaction_details,omitempty"`
    CreatedAt        time.Time           `gorm:"index" json:"created_at"`
    UpdatedAt        time.Time           `json:"updated_at"`
    DeletedAt        gorm.DeletedAt      `gorm:"index" json:"-"`
}

type ProductResponse struct {
	ID             uint      `json:"id"`
    Name           string    `json:"name"`
    CostPrice      float64   `json:"cost_price"`
    SellingPrice   float64   `json:"selling_price"`
    Stock          int       `json:"stock"`
    AvailableStock int       `json:"available_stock"`
    Category       string    `json:"category"`
    Image          string    `json:"image"`
    HasRecipe      bool      `json:"has_recipe"`
    Profit         float64   `json:"profit"`
    CreatedAt      time.Time `json:"created_at"`
}

type ProductRequest struct {
	Name         string  `json:"name" binding:"required"`
    CostPrice    float64 `json:"cost_price" binding:"min=0"`
    SellingPrice float64 `json:"selling_price" binding:"required,min=0"`
    Stock        int     `json:"stock" binding:"min=0"`
    Category     string  `json:"category"`
    Image        string  `json:"image"`
}

// GetAvailableStock menghitung stok tersedia dari bahan baku
// Jika produk punya recipe, hitung dari bahan baku
// Jika tidak, gunakan field stock
func (p *Product) GetAvailableStock(db *gorm.DB) int {
	// Jika produk tidak punya recipe, gunakan stock field
	if len(p.Recipes) == 0 {
		return p.Stock
	}
	
	// Load recipes dengan materials jika belum di-load
	if len(p.Recipes) > 0 && p.Recipes[0].Material.ID == 0 {
		db.Preload("Recipes.Material").First(&p, p.ID)
	}
	
	// Hitung berapa banyak produk yang bisa dibuat dari bahan baku
	minStock := 999999
	for _, recipe := range p.Recipes {
		if recipe.QuantityUsed <= 0 {
			continue
		}
		canMake := int(recipe.Material.Stock / recipe.QuantityUsed)
		if canMake < minStock {
			minStock = canMake
		}
	}
	
	if minStock == 999999 {
		return 0
	}
	return minStock
}

// before create hook
func (p *Product) BeforeCreate(tx *gorm.DB) error {
	if p.Category == "" {
		p.Category = "Umum"
	}
	return nil
}