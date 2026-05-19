package models

import (
	"time"
)

type Transaction struct {
	ID            uint                `gorm:"primaryKey" json:"id"`
    TotalAmount   float64             `gorm:"type:decimal(10,2);not null" json:"total_amount"`
    TotalProfit   float64             `gorm:"type:decimal(10,2);not null" json:"total_profit"`
    CashReceived  float64             `gorm:"type:decimal(10,2);not null" json:"cash_received"`
    ChangeAmount  float64             `gorm:"type:decimal(10,2);not null" json:"change_amount"`
    PaymentMethod string              `gorm:"size:20;default:'CASH'" json:"payment_method"`
    CashierName   string              `gorm:"size:100;default:'System'" json:"cashier_name"`
    Notes         string              `gorm:"type:text" json:"notes"`
    Details       []TransactionDetail `gorm:"foreignKey:TransactionID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"details,omitempty"`
    CreatedAt     time.Time           `json:"created_at"`
}

type TransactionDetail struct {
	ID            uint        `gorm:"primaryKey" json:"id"`
    TransactionID uint        `gorm:"not null;index" json:"transaction_id"`
    ProductID     uint        `gorm:"not null;index" json:"product_id"`
    ProductName   string      `gorm:"size:100" json:"product_name"`
    Qty           int         `gorm:"not null" json:"qty"`
    PricePerUnit  float64     `gorm:"type:decimal(10,2);not null" json:"price_per_unit"`
    TotalPrice    float64     `gorm:"type:decimal(10,2);not null" json:"total_price"`
    ProfitPerUnit float64     `gorm:"type:decimal(10,2);not null" json:"profit_per_unit"`
    Transaction   Transaction `gorm:"foreignKey:TransactionID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"transaction,omitempty"`
    Product       Product     `gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT" json:"product,omitempty"`
    CreatedAt     time.Time   `json:"created_at"`
}

type CartItem struct {
	ProductID uint `json:"product_id" binding:"required"`
    Quantity  int  `json:"quantity" binding:"required,min=1"`
}

type TransactionRequest struct {
	CashReceived float64    `json:"cash_received" binding:"required,min=0"`
    Items        []CartItem `json:"items" binding:"required,min=1"`
    PaymentMethod string    `json:"payment_method" binding:"required"`
    CashierName   string    `json:"cashier_name"`
    Notes         string    `json:"notes"`
}

type ReportRequest struct {
	StartDate string `json:"start_date" binding:"required"`
    EndDate   string `json:"end_date" binding:"required"`
}

type PeriodComparison struct {
	CurrentPeriod  SalesReport `json:"current_period"`
	PreviousPeriod SalesReport `json:"previous_period"`
	PercentChange  float64     `json:"percent_change"`
	Trend          string      `json:"trend"` // "up", "down", "stable"
}

type SalesReport struct {
	Period           string  `json:"period"`
    TotalSales       float64 `json:"total_sales"`
    TotalProfit      float64 `json:"total_profit"`
    TransactionCount int     `json:"transaction_count"`
    AvgTransaction   float64 `json:"avg_transaction"`
}

type TopProduct struct {
	ProductID   uint    `json:"product_id"`
	ProductName string  `json:"product_name"`
	TotalSold   int     `json:"total_sold"`
	TotalAmount float64 `json:"total_amount"`
	TotalProfit float64 `json:"total_profit"`
}

type DailyReport struct {
	Date             string  `json:"date"`
    TotalSales       float64 `json:"total_sales"`
    TotalProfit      float64 `json:"total_profit"`
    TransactionCount int     `json:"transaction_count"`
}