package controllers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"backend/config"
	"backend/models"
	"backend/utils"
)

type ProfitSummary struct {
	TotalRevenue    float64 `json:"total_revenue"`
	TotalCost       float64 `json:"total_cost"`
	TotalProfit     float64 `json:"total_profit"`
	ProfitMargin    float64 `json:"profit_margin"`
	TransactionCount int    `json:"transaction_count"`
}

type ProductProfit struct {
	ProductName   string  `json:"product_name"`
	TotalSold     int     `json:"total_sold"`
	Revenue       float64 `json:"revenue"`
	Cost          float64 `json:"cost"`
	Profit        float64 `json:"profit"`
	ProfitMargin  float64 `json:"profit_margin"`
}

type ProfitController struct{}

func (pc *ProfitController) GetProfitSummary(c *gin.Context) {
	GetProfitSummary(c)
}

func (pc *ProfitController) GetProductProfitAnalysis(c *gin.Context) {
	GetProductProfitAnalysis(c)
}

func (pc *ProfitController) GetDailyProfitTrend(c *gin.Context) {
	GetDailyProfitTrend(c)
}

func (pc *ProfitController) GetProfitAnalysis(c *gin.Context) {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	if startDate == "" || endDate == "" {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("start_date dan end_date harus diisi", nil))
		return
	}

	var transactions []models.Transaction
	query := config.DB.Preload("Details").
		Where("DATE(created_at) BETWEEN ? AND ?", startDate, endDate)

	if err := query.Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, utils.ErrorResponse("Gagal mengambil data transaksi", err))
		return
	}

	// Load all products once
	var products []models.Product
	config.DB.Find(&products)
	productMap := make(map[string]float64)
	for _, p := range products {
		productMap[p.Name] = p.CostPrice
	}

	var totalRevenue, totalCost, totalProfit float64
	transactionCount := len(transactions)

	for _, transaction := range transactions {
		totalRevenue += transaction.TotalAmount
		totalProfit += transaction.TotalProfit
		
		for _, detail := range transaction.Details {
			if costPrice, exists := productMap[detail.ProductName]; exists {
				totalCost += costPrice * float64(detail.Qty)
			}
		}
	}

	profitMargin := 0.0
	if totalRevenue > 0 {
		profitMargin = (totalProfit / totalRevenue) * 100
	}

	response := utils.SuccessResponse("Berhasil mengambil analisis profit", gin.H{
		"period": gin.H{
			"start_date": startDate,
			"end_date":   endDate,
		},
		"summary": gin.H{
			"total_revenue":     totalRevenue,
			"total_cost":        totalCost,
			"total_profit":      totalProfit,
			"profit_margin":     profitMargin,
			"transaction_count": transactionCount,
		},
	})
	c.JSON(http.StatusOK, response)
}

func GetProfitSummary(c *gin.Context) {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	var transactions []models.Transaction
	query := config.DB.Preload("Details")

	if startDate != "" && endDate != "" {
		query = query.Where("DATE(created_at) BETWEEN ? AND ?", startDate, endDate)
	}

	if err := query.Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	var totalRevenue, totalProfit float64
	transactionCount := len(transactions)

	for _, transaction := range transactions {
		totalRevenue += transaction.TotalAmount
		totalProfit += transaction.TotalProfit
	}

	totalCost := totalRevenue - totalProfit
	profitMargin := 0.0
	if totalRevenue > 0 {
		profitMargin = (totalProfit / totalRevenue) * 100
	}

	summary := ProfitSummary{
		TotalRevenue:     totalRevenue,
		TotalCost:        totalCost,
		TotalProfit:      totalProfit,
		ProfitMargin:     profitMargin,
		TransactionCount: transactionCount,
	}

	c.JSON(http.StatusOK, summary)
}

func GetProductProfitAnalysis(c *gin.Context) {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	var details []models.TransactionDetail
	query := config.DB.Joins("JOIN transactions ON transactions.id = transaction_details.transaction_id")

	if startDate != "" && endDate != "" {
		query = query.Where("DATE(transactions.created_at) BETWEEN ? AND ?", startDate, endDate)
	}

	if err := query.Find(&details).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Load all products once
	var products []models.Product
	config.DB.Find(&products)
	productMap := make(map[string]float64)
	for _, p := range products {
		productMap[p.Name] = p.CostPrice
	}

	profitMap := make(map[string]*ProductProfit)

	for _, detail := range details {
		if _, exists := profitMap[detail.ProductName]; !exists {
			profitMap[detail.ProductName] = &ProductProfit{
				ProductName: detail.ProductName,
			}
		}

		profit := profitMap[detail.ProductName]
		profit.TotalSold += detail.Qty
		profit.Revenue += detail.TotalPrice

		if costPrice, exists := productMap[detail.ProductName]; exists {
			profit.Cost += costPrice * float64(detail.Qty)
		}
	}

	var result []ProductProfit
	for _, profit := range profitMap {
		profit.Profit = profit.Revenue - profit.Cost
		if profit.Revenue > 0 {
			profit.ProfitMargin = (profit.Profit / profit.Revenue) * 100
		}
		result = append(result, *profit)
	}

	c.JSON(http.StatusOK, result)
}

func GetDailyProfitTrend(c *gin.Context) {
	type DailyProfit struct {
		Date    string  `json:"date"`
		Revenue float64 `json:"revenue"`
		Cost    float64 `json:"cost"`
		Profit  float64 `json:"profit"`
	}

	var result []DailyProfit

	for i := 0; i < 7; i++ {
		date := time.Now().AddDate(0, 0, -i).Format("2006-01-02")

		var transactions []models.Transaction
		config.DB.Where("DATE(created_at) = ?", date).Find(&transactions)

		var dayRevenue, dayProfit float64
		for _, transaction := range transactions {
			dayRevenue += transaction.TotalAmount
			dayProfit += transaction.TotalProfit
		}

		result = append(result, DailyProfit{
			Date:    date,
			Revenue: dayRevenue,
			Cost:    dayRevenue - dayProfit,
			Profit:  dayProfit,
		})
	}

	c.JSON(http.StatusOK, result)
}
