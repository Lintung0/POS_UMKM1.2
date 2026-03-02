package controllers

import (
	"backend/config"
	"backend/models"
	"fmt"
	"time"

	"github.com/gin-gonic/gin"
)

type ReportController struct{}

// ExportDailyReportCSV - Export daily report to CSV
func (rc *ReportController) ExportDailyReportCSV(c *gin.Context) {
	date := c.DefaultQuery("date", time.Now().Format("2006-01-02"))

	var transactions []models.Transaction
	config.DB.Where("DATE(created_at) = ?", date).
		Preload("Details").
		Order("created_at desc").
		Find(&transactions)

	// Generate CSV
	csv := "No,Tanggal,Kasir,Metode Pembayaran,Total,Profit\n"
	
	for _, t := range transactions {
		csv += fmt.Sprintf("%d,%s,%s,%s,%.0f,%.0f\n",
			t.ID,
			t.CreatedAt.Format("2006-01-02 15:04:05"),
			t.CashierName,
			t.PaymentMethod,
			t.TotalAmount,
			t.TotalProfit,
		)
	}

	// Set headers for download
	c.Header("Content-Type", "text/csv; charset=utf-8")
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=laporan-harian-%s.csv", date))
	c.String(200, csv)
}

// ExportMonthlyReportCSV - Export monthly report to CSV
func (rc *ReportController) ExportMonthlyReportCSV(c *gin.Context) {
	month := c.DefaultQuery("month", time.Now().Format("2006-01"))

	var transactions []models.Transaction
	config.DB.Where("DATE_FORMAT(created_at, '%Y-%m') = ?", month).
		Preload("Details").
		Order("created_at desc").
		Find(&transactions)

	// Generate CSV
	csv := "No,Tanggal,Kasir,Metode Pembayaran,Total,Profit\n"
	
	var totalSales, totalProfit float64
	for _, t := range transactions {
		csv += fmt.Sprintf("%d,%s,%s,%s,%.0f,%.0f\n",
			t.ID,
			t.CreatedAt.Format("2006-01-02 15:04:05"),
			t.CashierName,
			t.PaymentMethod,
			t.TotalAmount,
			t.TotalProfit,
		)
		totalSales += t.TotalAmount
		totalProfit += t.TotalProfit
	}

	// Add summary
	csv += fmt.Sprintf("\nSUMMARY,,,Total Transaksi: %d,%.0f,%.0f\n",
		len(transactions),
		totalSales,
		totalProfit,
	)

	// Set headers for download
	c.Header("Content-Type", "text/csv; charset=utf-8")
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=laporan-bulanan-%s.csv", month))
	c.String(200, csv)
}

// ExportAllTransactionsCSV - Export all transactions to CSV
func (rc *ReportController) ExportAllTransactionsCSV(c *gin.Context) {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	query := config.DB.Model(&models.Transaction{})
	
	if startDate != "" {
		query = query.Where("DATE(created_at) >= ?", startDate)
	}
	if endDate != "" {
		query = query.Where("DATE(created_at) <= ?", endDate)
	}

	var transactions []models.Transaction
	query.Preload("Details").
		Order("created_at desc").
		Find(&transactions)

	// Generate CSV
	csv := "No,Tanggal,Kasir,Metode Pembayaran,Total,Profit,Catatan\n"
	
	for _, t := range transactions {
		csv += fmt.Sprintf("%d,%s,%s,%s,%.0f,%.0f,%s\n",
			t.ID,
			t.CreatedAt.Format("2006-01-02 15:04:05"),
			t.CashierName,
			t.PaymentMethod,
			t.TotalAmount,
			t.TotalProfit,
			t.Notes,
		)
	}

	// Set headers for download
	filename := fmt.Sprintf("laporan-transaksi-%s.csv", time.Now().Format("2006-01-02"))
	c.Header("Content-Type", "text/csv; charset=utf-8")
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s", filename))
	c.String(200, csv)
}
