package models

import (
	"time"
)

type Production struct {
	ID               uint                 `gorm:"primaryKey" json:"id"`
	ProductID        uint                 `gorm:"not null;index" json:"product_id"`
	QuantityProduced int                  `gorm:"not null" json:"quantity_produced"`
	TotalCost        float64              `gorm:"type:decimal(10,2);not null" json:"total_cost"`
	CostPerUnit      float64              `gorm:"type:decimal(10,2);not null" json:"cost_per_unit"`
	BatchNumber      string               `gorm:"size:50;index" json:"batch_number"`
	ProducedBy       string               `gorm:"size:100;default:'System'" json:"produced_by"`
	Notes            string               `gorm:"type:text" json:"notes"`
	Product          Product              `gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"product,omitempty"`
	Materials        []ProductionMaterial `gorm:"foreignKey:ProductionID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"materials,omitempty"`
	CreatedAt        time.Time            `gorm:"index" json:"created_at"`
}

type ProductionMaterial struct {
	ID           uint        `gorm:"primaryKey" json:"id"`
	ProductionID uint        `gorm:"not null;index" json:"production_id"`
	MaterialID   uint        `gorm:"not null;index" json:"material_id"`
	QuantityUsed float64     `gorm:"type:decimal(10,2);not null" json:"quantity_used"`
	Cost         float64     `gorm:"type:decimal(10,2);not null" json:"cost"`
	Production   Production  `gorm:"foreignKey:ProductionID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"production,omitempty"`
	Material     RawMaterial `gorm:"foreignKey:MaterialID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"material,omitempty"`
	CreatedAt    time.Time   `json:"created_at"`
}

type ProductionRequest struct {
	ProductID  uint   `json:"product_id" binding:"required"`
	Quantity   int    `json:"quantity" binding:"required,min=1"`
	ProducedBy string `json:"produced_by"`
	Notes      string `json:"notes"`
}
