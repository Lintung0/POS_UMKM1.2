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

// GetAvailableStock menghitung stok tersedia
// Produk dengan resep: hitung dari bahan baku
// Produk tanpa resep: gunakan field stock
func (p *Product) GetAvailableStock(db *gorm.DB) int {
	if !p.HasRecipe {
		return p.Stock
	}

	// Load jika belum ada
	if len(p.Recipes) == 0 {
		db.Preload("Material").Where("product_id = ?", p.ID).Find(&p.Recipes)
	}

	if len(p.Recipes) == 0 {
		return 0
	}

	minStock := int(^uint(0) >> 1)
	for _, recipe := range p.Recipes {
		if recipe.QuantityUsed <= 0 {
			continue
		}
		canMake := int(recipe.Material.Stock / recipe.QuantityUsed)
		if canMake < minStock {
			minStock = canMake
		}
	}

	if minStock == int(^uint(0)>>1) {
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