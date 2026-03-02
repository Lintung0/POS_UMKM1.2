package controllers

import (
	"backend/config"
	"backend/models"
	"backend/utils"
	"context"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type TransactionController struct{}

// CreateTransaction - Create new transaction (KASIR FUNCTION)
func (tc *TransactionController) CreateTransaction(c *gin.Context) {
	var req models.TransactionRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		response := utils.ErrorResponse("Data transaksi tidak valid", err)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Validasi uang yang diterima
	if req.CashReceived <= 0 {
		response := utils.ErrorResponse("Uang yang diterima harus lebih dari 0", nil)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Mulai transaksi database dengan timeout
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	
	tx := config.DB.WithContext(ctx).Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	var totalAmount, totalProfit float64
	var transactionDetails []models.TransactionDetail

	// LOGIKA BISNIS PENTING: Hitung total dan kurangi stok
	for _, item := range req.Items {
		var product models.Product

		// Ambil produk dengan resep untuk validasi bahan baku - WITH LOCK
		if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
			Preload("Recipes.Material").
			First(&product, item.ProductID).Error; err != nil {
			tx.Rollback()
			response := utils.ErrorResponse("Produk tidak ditemukan", err)
			c.JSON(http.StatusNotFound, response)
			return
		}

		// ==============================================
		// LOGIKA PENTING: VALIDASI STOK DARI BAHAN BAKU
		// ==============================================
		availableStock := product.GetAvailableStock(tx)
		
		if availableStock <= 0 {
			tx.Rollback()
			msg := fmt.Sprintf("Produk %s habis", product.Name)
			response := utils.ErrorResponse(msg, nil)
			c.JSON(http.StatusBadRequest, response)
			return
		}

		if availableStock < item.Quantity {
			tx.Rollback()
			msg := fmt.Sprintf("Stok %s tidak cukup. Tersedia: %d, Dibutuhkan: %d",
				product.Name, availableStock, item.Quantity)
			response := utils.ErrorResponse(msg, nil)
			c.JSON(http.StatusBadRequest, response)
			return
		}

		// ==============================================
		// LOGIKA PENTING: KURANGI STOK BAHAN BAKU OTOMATIS
		// ==============================================
		// Cek apakah produk memiliki resep (menggunakan bahan baku)
		if len(product.Recipes) > 0 {
			// Produk menggunakan bahan baku - kurangi stok bahan baku
			for _, recipe := range product.Recipes {
				totalMaterialNeeded := recipe.QuantityUsed * float64(item.Quantity)

				// Lock material row and check stock
				var material models.RawMaterial
				if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
					First(&material, recipe.MaterialID).Error; err != nil {
					tx.Rollback()
					response := utils.ErrorResponse("Bahan baku tidak ditemukan", err)
					c.JSON(http.StatusInternalServerError, response)
					return
				}

				// Cek ketersediaan bahan baku
				if material.Stock < totalMaterialNeeded {
					tx.Rollback()
					msg := fmt.Sprintf("Bahan baku %s tidak cukup. Tersedia: %.2f %s, Dibutuhkan: %.2f %s",
						material.Name, material.Stock, material.Unit,
						totalMaterialNeeded, material.Unit)
					response := utils.ErrorResponse(msg, nil)
					c.JSON(http.StatusBadRequest, response)
					return
				}

				// Kurangi stok bahan baku dengan atomic update
				result := tx.Model(&models.RawMaterial{}).
					Where("id = ? AND stock >= ?", recipe.MaterialID, totalMaterialNeeded).
					Update("stock", gorm.Expr("stock - ?", totalMaterialNeeded))
				
				if result.Error != nil {
					tx.Rollback()
					response := utils.ErrorResponse("Gagal mengurangi stok bahan baku", result.Error)
					c.JSON(http.StatusInternalServerError, response)
					return
				}

				// Verifikasi update berhasil
				if result.RowsAffected == 0 {
					tx.Rollback()
					response := utils.ErrorResponse("Stok bahan baku berubah saat transaksi", nil)
					c.JSON(http.StatusConflict, response)
					return
				}
			}
			
			// PENTING: Kurangi juga stok produk jadi setelah bahan baku dikurangi
			result := tx.Model(&product).
				Where("id = ? AND stock >= ?", product.ID, item.Quantity).
				Update("stock", gorm.Expr("stock - ?", item.Quantity))
			
			if result.Error != nil {
				tx.Rollback()
				response := utils.ErrorResponse("Gagal mengurangi stok produk", result.Error)
				c.JSON(http.StatusInternalServerError, response)
				return
			}

			if result.RowsAffected == 0 {
				tx.Rollback()
				response := utils.ErrorResponse("Stok produk berubah saat transaksi", nil)
				c.JSON(http.StatusConflict, response)
				return
			}
		} else {
			// Produk tidak menggunakan bahan baku - langsung kurangi stok produk
			// Lock product and check stock
			var productCheck models.Product
			if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
				First(&productCheck, product.ID).Error; err != nil {
				tx.Rollback()
				response := utils.ErrorResponse("Produk tidak ditemukan", err)
				c.JSON(http.StatusInternalServerError, response)
				return
			}

			if productCheck.Stock < item.Quantity {
				tx.Rollback()
				msg := fmt.Sprintf("Stok %s tidak cukup. Tersedia: %d, Dibutuhkan: %d",
					product.Name, productCheck.Stock, item.Quantity)
				response := utils.ErrorResponse(msg, nil)
				c.JSON(http.StatusBadRequest, response)
				return
			}

			// Kurangi stok produk jadi dengan atomic update
			result := tx.Model(&product).
				Where("id = ? AND stock >= ?", product.ID, item.Quantity).
				Update("stock", gorm.Expr("stock - ?", item.Quantity))
			
			if result.Error != nil {
				tx.Rollback()
				response := utils.ErrorResponse("Gagal mengurangi stok produk", result.Error)
				c.JSON(http.StatusInternalServerError, response)
				return
			}

			if result.RowsAffected == 0 {
				tx.Rollback()
				response := utils.ErrorResponse("Stok produk berubah saat transaksi", nil)
				c.JSON(http.StatusConflict, response)
				return
			}
		}

		// Hitung keuntungan per unit
		profitPerUnit := product.SellingPrice - product.CostPrice

		// Hitung total untuk item ini
		itemTotalPrice := product.SellingPrice * float64(item.Quantity)
		itemTotalProfit := profitPerUnit * float64(item.Quantity)

		// Tambahkan ke total
		totalAmount += itemTotalPrice
		totalProfit += itemTotalProfit

		// Simpan detail transaksi
		detail := models.TransactionDetail{
			ProductID:     product.ID,
			ProductName:   product.Name,
			Qty:           item.Quantity,
			PricePerUnit:  product.SellingPrice,
			TotalPrice:    itemTotalPrice,
			ProfitPerUnit: profitPerUnit,
		}
		transactionDetails = append(transactionDetails, detail)
	}

	// Validasi uang bayar
	if req.CashReceived < totalAmount {
		tx.Rollback()
		msg := fmt.Sprintf("Uang tidak cukup. Total: %.2f, Diterima: %.2f, Kekurangan: %.2f",
			totalAmount, req.CashReceived, totalAmount-req.CashReceived)
		response := utils.ErrorResponse(msg, nil)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Hitung kembalian
	changeAmount := req.CashReceived - totalAmount

	// Buat transaksi utama
	transaction := models.Transaction{
		TotalAmount:   totalAmount,
		TotalProfit:   totalProfit,
		CashReceived:  req.CashReceived,
		ChangeAmount:  changeAmount,
		PaymentMethod: req.PaymentMethod,
		CashierName:   req.CashierName,
		Notes:         req.Notes,
	}

	// Simpan transaksi
	if err := tx.Create(&transaction).Error; err != nil {
		tx.Rollback()
		response := utils.ErrorResponse("Gagal membuat transaksi", err)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	// Simpan detail transaksi
	for i := range transactionDetails {
		transactionDetails[i].TransactionID = transaction.ID
		if err := tx.Create(&transactionDetails[i]).Error; err != nil {
			tx.Rollback()
			response := utils.ErrorResponse("Gagal membuat detail transaksi", err)
			c.JSON(http.StatusInternalServerError, response)
			return
		}
	}

	// Commit transaksi
	if err := tx.Commit().Error; err != nil {
		response := utils.ErrorResponse("Transaksi gagal", err)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	// Ambil data transaksi lengkap untuk response
	var fullTransaction models.Transaction
	config.DB.Preload("Details.Product").First(&fullTransaction, transaction.ID)

	responseData := gin.H{
		"transaction": fullTransaction,
		"change":      changeAmount,
		"summary": gin.H{
			"total_amount":  totalAmount,
			"total_profit":  totalProfit,
			"cash_received": req.CashReceived,
			"change_amount": changeAmount,
			"item_count":    len(req.Items),
		},
	}

	response := utils.SuccessResponse("Transaksi berhasil diproses", responseData)
	c.JSON(http.StatusCreated, response)
}

// GetAllTransactions - Get all transactions with pagination
func (tc *TransactionController) GetAllTransactions(c *gin.Context) {
	var transactions []models.Transaction

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	offset := (page - 1) * limit

	var total int64
	config.DB.Model(&models.Transaction{}).Count(&total)

	result := config.DB.
		Preload("Details.Product").
		Limit(limit).
		Offset(offset).
		Order("created_at desc").
		Find(&transactions)

	if result.Error != nil {
		response := utils.ErrorResponse("Gagal mengambil data transaksi", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	responseData := gin.H{
		"transactions": transactions,
		"pagination": gin.H{
			"page":       page,
			"limit":      limit,
			"total":      total,
			"total_page": (int(total) + limit - 1) / limit,
		},
	}

	response := utils.SuccessResponse("Berhasil mengambil data transaksi", responseData)
	c.JSON(http.StatusOK, response)
}

// GetTransactionByID - Get single transaction by ID
func (tc *TransactionController) GetTransactionByID(c *gin.Context) {
	id := c.Param("id")

	var transaction models.Transaction
	result := config.DB.
		Preload("Details.Product").
		First(&transaction, id)

	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			response := utils.ErrorResponse("Transaksi tidak ditemukan", nil)
			c.JSON(http.StatusNotFound, response)
			return
		}
		response := utils.ErrorResponse("Gagal mengambil data transaksi", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	response := utils.SuccessResponse("Berhasil mengambil data transaksi", transaction)
	c.JSON(http.StatusOK, response)
}

// GetDailyReport - Get daily sales report
func (tc *TransactionController) GetDailyReport(c *gin.Context) {
	date := c.DefaultQuery("date", time.Now().Format("2006-01-02"))

	var report models.DailyReport

	// Query untuk laporan harian
	query := `
        SELECT 
            DATE(created_at) as date,
            COUNT(*) as transaction_count,
            COALESCE(SUM(total_amount), 0) as total_sales,
            COALESCE(SUM(total_profit), 0) as total_profit
        FROM transactions
        WHERE DATE(created_at) = ?
        GROUP BY DATE(created_at)
    `

	result := config.DB.Raw(query, date).Scan(&report)
	if result.Error != nil {
		response := utils.ErrorResponse("Gagal mengambil laporan harian", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	// Jika tidak ada transaksi pada tanggal tersebut
	if report.Date == "" {
		report = models.DailyReport{
			Date:             date,
			TotalSales:       0,
			TotalProfit:      0,
			TransactionCount: 0,
		}
	}

	response := utils.SuccessResponse("Berhasil mengambil laporan harian", report)
	c.JSON(http.StatusOK, response)
}

// GetMonthlyReport - Get monthly sales report
func (tc *TransactionController) GetMonthlyReport(c *gin.Context) {
	monthParam := c.DefaultQuery("month", time.Now().Format("2006-01"))

	var report models.SalesReport
	var transactions []models.Transaction

	// Parse month parameter (format: YYYY-MM)
	startDate := monthParam + "-01"
	
	// Parse untuk validasi format
	_, err := time.Parse("2006-01-02", startDate)
	if err != nil {
		response := utils.ErrorResponse("Format bulan tidak valid (gunakan YYYY-MM)", err)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Query untuk laporan bulanan menggunakan MySQL syntax
	query := `
        SELECT 
            COUNT(*) as transaction_count,
            COALESCE(SUM(total_amount), 0) as total_sales,
            COALESCE(SUM(total_profit), 0) as total_profit
        FROM transactions
        WHERE YEAR(created_at) = YEAR(?) AND MONTH(created_at) = MONTH(?)
    `

	result := config.DB.Raw(query, startDate, startDate).Scan(&report)
	if result.Error != nil {
		response := utils.ErrorResponse("Gagal mengambil laporan bulanan", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	// Hitung rata-rata transaksi
	if report.TransactionCount > 0 {
		report.AvgTransaction = report.TotalSales / float64(report.TransactionCount)
	}

	report.Period = monthParam

	// Ambil detail transaksi untuk bulan tersebut
	config.DB.
		Where("YEAR(created_at) = YEAR(?) AND MONTH(created_at) = MONTH(?)", startDate, startDate).
		Order("created_at desc").
		Find(&transactions)

	responseData := gin.H{
		"report":       report,
		"transactions": transactions,
	}

	response := utils.SuccessResponse("Berhasil mengambil laporan bulanan", responseData)
	c.JSON(http.StatusOK, response)
}

// GetPeriodComparison - Compare current period with previous period
func (tc *TransactionController) GetPeriodComparison(c *gin.Context) {
	periodType := c.DefaultQuery("type", "monthly") // daily, weekly, monthly
	
	var currentStart, currentEnd, prevStart, prevEnd time.Time
	now := time.Now()
	
	switch periodType {
	case "daily":
		currentStart = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
		currentEnd = currentStart.Add(24 * time.Hour)
		prevStart = currentStart.Add(-24 * time.Hour)
		prevEnd = currentStart
	case "weekly":
		weekday := int(now.Weekday())
		currentStart = now.Add(-time.Duration(weekday) * 24 * time.Hour)
		currentStart = time.Date(currentStart.Year(), currentStart.Month(), currentStart.Day(), 0, 0, 0, 0, now.Location())
		currentEnd = currentStart.Add(7 * 24 * time.Hour)
		prevStart = currentStart.Add(-7 * 24 * time.Hour)
		prevEnd = currentStart
	default: // monthly
		currentStart = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
		currentEnd = currentStart.AddDate(0, 1, 0)
		prevStart = currentStart.AddDate(0, -1, 0)
		prevEnd = currentStart
	}
	
	// Get current period stats
	var currentReport models.SalesReport
	query := `
		SELECT 
			COUNT(*) as transaction_count,
			COALESCE(SUM(total_amount), 0) as total_sales,
			COALESCE(SUM(total_profit), 0) as total_profit
		FROM transactions
		WHERE created_at >= ? AND created_at < ?
	`
	config.DB.Raw(query, currentStart, currentEnd).Scan(&currentReport)
	if currentReport.TransactionCount > 0 {
		currentReport.AvgTransaction = currentReport.TotalSales / float64(currentReport.TransactionCount)
	}
	
	// Get previous period stats
	var prevReport models.SalesReport
	config.DB.Raw(query, prevStart, prevEnd).Scan(&prevReport)
	if prevReport.TransactionCount > 0 {
		prevReport.AvgTransaction = prevReport.TotalSales / float64(prevReport.TransactionCount)
	}
	
	// Calculate percent change
	var percentChange float64
	var trend string
	if prevReport.TotalSales > 0 {
		percentChange = ((currentReport.TotalSales - prevReport.TotalSales) / prevReport.TotalSales) * 100
	}
	
	if percentChange > 5 {
		trend = "up"
	} else if percentChange < -5 {
		trend = "down"
	} else {
		trend = "stable"
	}
	
	comparison := models.PeriodComparison{
		CurrentPeriod:  currentReport,
		PreviousPeriod: prevReport,
		PercentChange:  percentChange,
		Trend:          trend,
	}
	
	response := utils.SuccessResponse("Berhasil membandingkan periode", comparison)
	c.JSON(http.StatusOK, response)
}

// GetPeakHours - Get busiest hours
func (tc *TransactionController) GetPeakHours(c *gin.Context) {
	date := c.DefaultQuery("date", time.Now().Format("2006-01-02"))
	
	type HourStat struct {
		Hour  int     `json:"hour"`
		Count int     `json:"count"`
		Sales float64 `json:"sales"`
	}
	
	var stats []HourStat
	query := `
		SELECT 
			HOUR(created_at) as hour,
			COUNT(*) as count,
			COALESCE(SUM(total_amount), 0) as sales
		FROM transactions
		WHERE DATE(created_at) = ?
		GROUP BY HOUR(created_at)
		ORDER BY count DESC
	`
	
	config.DB.Raw(query, date).Scan(&stats)
	
	response := utils.SuccessResponse("Berhasil mengambil data jam sibuk", stats)
	c.JSON(http.StatusOK, response)
}
