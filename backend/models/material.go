package models

import (
	"time"
	"gorm.io/gorm"
)

type RawMaterial struct {
	ID           uint           `gorm:"primaryKey" json:"id"`
    Name         string         `gorm:"size:100;not null" json:"name"`
    Stock        float64        `gorm:"type:decimal(10,2);not null;default:0" json:"stock"`
    Unit         string         `gorm:"size:20;not null" json:"unit"`
    PricePerUnit float64        `gorm:"type:decimal(10,2);default:0" json:"price_per_unit"`
    MinStock     float64        `gorm:"type:decimal(10,2);default:10" json:"min_stock"`
    Supplier     string         `gorm:"size:100;default:''" json:"supplier"`
    Recipes      []Recipe       `gorm:"foreignKey:MaterialID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"recipes,omitempty"`
    CreatedAt    time.Time      `json:"created_at"`
    UpdatedAt    time.Time      `json:"updated_at"`
    DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

type RawMaterialRequest struct {
	Name         string  `json:"name" binding:"required"`
    Stock        float64 `json:"stock" binding:"min=0"`
    Unit         string  `json:"unit" binding:"required"`
    CostPerUnit  float64 `json:"cost_per_unit" binding:"min=0"`
    MinStock     float64 `json:"min_stock" binding:"min=0"`
    Supplier     string  `json:"supplier"`
}

type LowStockMaterial struct {
	ID          uint    `json:"id"`
    Name        string  `json:"name"`
    Stock       float64 `json:"stock"`
    Unit        string  `json:"unit"`
    MinStock    float64 `json:"min_stock"`
    StockStatus string  `json:"stock_status"`
}