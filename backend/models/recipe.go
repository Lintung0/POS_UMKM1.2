package models

import (
	"time"
)

type Recipe struct {
	ID           uint         `gorm:"primaryKey" json:"id"`
    ProductID    uint         `gorm:"not null;index" json:"product_id"`
    MaterialID   uint         `gorm:"not null;index" json:"material_id"`
    QuantityUsed float64      `gorm:"type:decimal(10,2);not null" json:"quantity_used"`
    Notes        string       `gorm:"type:text" json:"notes"`
    Product      Product      `gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"product,omitempty"`
    Material     RawMaterial  `gorm:"foreignKey:MaterialID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"material,omitempty"`
    CreatedAt    time.Time    `json:"created_at"`
    UpdatedAt    time.Time    `json:"updated_at"`
}

type RecipeRequest struct {
	MaterialID   uint    `json:"material_id" binding:"required"`
    QuantityUsed float64 `json:"quantity_used" binding:"required,min=0.01"`
    Notes        string  `json:"notes"`
}

type RecipeBatchRequest struct {
	ProductID uint           `json:"product_id" binding:"required"`
    Recipes   []RecipeRequest `json:"recipes" binding:"required,min=1"`
}