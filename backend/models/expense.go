package models

import (
	"time"
)

type Expense struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	Date        time.Time `gorm:"type:date;not null" json:"date"`
	Category    string    `gorm:"size:50;not null" json:"category"`
	Description string    `gorm:"type:text;not null" json:"description"`
	Amount      float64   `gorm:"type:decimal(10,2);not null" json:"amount"`
	CreatedBy   string    `gorm:"size:100" json:"created_by"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type ExpenseRequest struct {
	Date        string  `json:"date" binding:"required"`
	Category    string  `json:"category" binding:"required"`
	Description string  `json:"description" binding:"required"`
	Amount      float64 `json:"amount" binding:"required,min=0.01"`
}

type ExpenseSummary struct {
	TotalAmount float64            `json:"total_amount"`
	ByCategory  map[string]float64 `json:"by_category"`
	Count       int64              `json:"count"`
}
